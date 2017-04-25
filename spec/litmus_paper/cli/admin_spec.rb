require 'spec_helper'

describe 'litmusctl' do
  def _litmusctl(args)
    `bundle exec ruby -I lib bin/litmusctl #{args} -c #{TEST_CONFIG}`
  end

  before(:all) do
    FileUtils.mkdir_p('tmp')
    CONFIG_FILE = 'tmp/test.config'
    system("cp #{TEST_CONFIG} #{CONFIG_FILE}")
    ENV['LITMUS_CONFIG'] = CONFIG_FILE
    system "bundle exec ruby -I lib bin/litmus -d -u #{TEST_UNICORN_CONFIG}"
    @litmus_pid = File.read("tmp/unicorn.pid").chomp.to_i
  end

  after(:all) do
    Process.kill("TERM", @litmus_pid)
  end

  describe 'help' do
    it "is displayed if no command is given" do
      expect(_litmusctl('')).to match("Commands:")
    end
  end

  describe 'list' do
    it "returns the list of services running" do
      expect(_litmusctl('list')).to match("test")
    end
  end

  describe 'status' do
    it 'returns the status of a service' do
      expect(_litmusctl('status test')).to match("Health: 0")
      expect(_litmusctl('status passing_test')).to match(/Health: \d\d/)
    end

    it "returns 'NOT FOUND' for a service that doesn't exist" do
      expect(_litmusctl('status unknown')).to match('NOT FOUND')
    end
  end

  describe "force" do
    it "can create a global downfile" do
      expect(_litmusctl('force down -r "for testing"')).to match("File created")

      status = _litmusctl('status test')
      expect(status).to match(/Health: 0/)
      expect(status).to match(/for testing/)
    end

    it "can create a global healthfile" do
      expect(_litmusctl('force health 88 -r "for testing"')).to match("File created")

      status = _litmusctl('status test')
      expect(status).to match(/Health: 0/) # This service is actually failing so we'll get 0 back
      expect(status).to match(/for testing 88/)
    end

    it "creates a downfile" do
      expect(_litmusctl('force down test -r "for testing"')).to match("File created")

      status = _litmusctl('status test')
      expect(status).to match(/Health: 0/)
      expect(status).to match(/for testing/)
    end

    it "creates a healthfile" do
      expect(_litmusctl('force health 88 test -r "for testing"')).to match("File created")

      status = _litmusctl('status test')
      expect(status).to match(/Health: 0/)
      expect(status).to match(/for testing 88/)
    end

    it 'removes an upfile for the service' do
      expect(_litmusctl('force up test -r "for testing"')).to match("File created")
      expect(_litmusctl('force up test -d')).to match("File deleted")

      status = _litmusctl('status passing_test')
      expect(status).to match(/Health: \d\d/)
      expect(status).not_to match(/for testing/)
    end

    it "removes a healthfile for the service" do
      expect(_litmusctl('force health 88 test -r "for testing"')).to match("File created")
      expect(_litmusctl('force health test -d')).to match("File deleted")
      status = _litmusctl('status passing_test')
      expect(status).to match(/Health: \d\d/)
      expect(status).not_to match(/for testing/)
    end

    it "returns not found if downfile doesn't exist" do
      expect(_litmusctl('force down test -d')).to match("NOT FOUND")
    end
  end

  describe "reload" do
    after(:each) do
      restore_config_file(CONFIG_FILE)
      Process.kill("HUP", @litmus_pid)
    end

    it "reloads on a USR1 signal" do
      expect(_litmusctl('status test')).to match("Health: 0")

      replace_config_file(CONFIG_FILE, :with => TEST_RELOAD_CONFIG)

      Process.kill("HUP", @litmus_pid)

      expect(_litmusctl('status foo')).to match("Health: 0")
    end
  end
end
