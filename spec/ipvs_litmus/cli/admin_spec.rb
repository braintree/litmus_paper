require 'spec_helper'


describe 'litmusctl' do
  def _litmusctl(args)
    `bundle exec ruby -I lib bin/litmusctl #{args} -p 9293`
  end

  before(:all) do
    system "bundle exec ruby -I lib bin/litmus -p 9293 -d -D /tmp/ipvs -c #{TEST_CONFIG} -P /tmp/ipvs.pid"
  end

  after(:all) do
    system "kill -9 `cat /tmp/ipvs.pid`"
  end

  describe 'status' do
    it 'returns the status of a service' do
      _litmusctl('status test').should match("Health: 0")
      _litmusctl('status passing_test').should match(/Health: \d\d/)
    end

    it "returns 'NOT FOUND' for a service that doesn't exist" do
      _litmusctl('status unknown').should match('NOT FOUND')
    end
  end

  describe 'down' do
    it 'creates a downfile for the service' do
      _litmusctl('down test -r "for testing"').should match("File created")

      status = _litmusctl('status test')
      status.should match(/Health: 0/)
      status.should match(/for testing/)
    end

    it 'removes a downfile for the service' do
      _litmusctl('down passing_test -r "for testing"').should match("File created")
      _litmusctl('down passing_test -d').should match("File deleted")

      status = _litmusctl('status passing_test')
      status.should match(/Health: \d\d/)
      status.should_not match(/for testing/)
    end

    it "returns not found if downfile doesn't exist" do
      _litmusctl('down test -d').should match("NOT FOUND")
    end
  end

  describe 'up' do
    it 'creates a upfile for the service' do
      _litmusctl('up test -r "for testing"').should match("File created")

      status = _litmusctl('status test')
      status.should match(/Health: 100/)
      status.should match(/for testing/)
    end

    it 'removes a upfile for the service' do
      _litmusctl('up test -r "for testing"').should match("File created")
      _litmusctl('up test -d').should match("File deleted")

      status = _litmusctl('status test')
      status.should match(/Health: 0/)
      status.should_not match(/for testing/)
    end

    it "returns not found if upfile doesn't exist" do
      _litmusctl('up test -d').should match("NOT FOUND")
    end
  end
end
