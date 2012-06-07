require 'spec_helper'


describe 'litmusctl' do
  def _litmusctl(args)
    puts "bundle exec ruby -I lib bin/litmusctl #{args} -p 9293"
    `bundle exec ruby -I lib bin/litmusctl #{args} -p 9293`
  end

  # before(:all) do
  #   puts "bundle exec ruby -I lib bin/litmus -p 9293 -d -D #{LitmusPaper.config_dir} -c #{TEST_CONFIG} -P /tmp/litmus.pid"
  #   `bundle exec ruby -I lib bin/litmus -p 9293 -d -D #{LitmusPaper.config_dir} -c #{TEST_CONFIG} -P /tmp/litmus.pid`
  #   SpecHelper.wait_for_service :host => '127.0.0.1', :port => 9293
  # end

  # after(:all) do
  #   puts "kill -9 `cat /tmp/litmus.pid`"
  #   system "kill -9 `cat /tmp/litmus.pid`"
  # end

  # describe 'list' do
  #   it "returns the list of services running" do
  #     _litmusctl('list').should match("test")
  #   end
  # end

  # describe 'status' do
  #   it 'returns the status of a service' do
  #     _litmusctl('status test').should match("Health: 0")
  #     _litmusctl('status passing_test').should match(/Health: \\d\\d/)
  #   end

  #   it "returns 'NOT FOUND' for a service that doesn't exist" do
  #     _litmusctl('status unknown').should match('NOT FOUND')
  #   end
  # end

  # describe "force" do
  #   it "can create a global downfile" do
  #     _litmusctl('force down -r "for testing"').should match("File created")

  #     status = _litmusctl('status test')
  #     status.should match(/Health: 0/)
  #     status.should match(/for testing/)
  #   end

  #   it "creates a downfile" do
  #     _litmusctl('force down test -r "for testing"').should match("File created")

  #     status = _litmusctl('status test')
  #     status.should match(/Health: 0/)
  #     status.should match(/for testing/)
  #   end

  #   it 'removes an upfile for the service' do
  #     _litmusctl('force up test -r "for testing"').should match("File created")
  #     _litmusctl('force up test -d').should match("File deleted")

  #     status = _litmusctl('status passing_test')
  #     status.should match(/Health: \\d\\d/)
  #     status.should_not match(/for testing/)
  #   end

  #   it "returns not found if downfile doesn't exist" do
  #     _litmusctl('force down test -d').should match("NOT FOUND")
  #   end
  # end
end
