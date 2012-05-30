require 'spec_helper'

describe IPVSLitmus::Dependency::HTTP do
  before(:all) do
    server_start = system "bundle exec rackup spec/support/http_test_server_config.ru --port 9294 --pid /tmp/http-test-server.pid --daemonize"
    sleep 5
    @url = "http://127.0.0.1:9294"
  end

  after(:all) do
    system "kill -9 `cat /tmp/http-test-server.pid`"
  end

  describe "#available?" do
    context "http method" do
      it "uses the given http method when making the request" do
        check = IPVSLitmus::Dependency::HTTP.new("#{@url}/method", :method => "GET", :content => "POST")
        check.should_not be_available

        check = IPVSLitmus::Dependency::HTTP.new("#{@url}/method", :method => "POST", :content => "POST")
        check.should be_available
      end
    end

    it "is true when response is 200" do
      check = IPVSLitmus::Dependency::HTTP.new("#{@url}/status/200")
      check.should be_available
    end

    it "is true when response is 200 and expected content matches" do
      check = IPVSLitmus::Dependency::HTTP.new("#{@url}/status/200", :content => "200 OK")
      check.should be_available
    end

    it "is false when response is 200, but does not match content" do
      check = IPVSLitmus::Dependency::HTTP.new("#{@url}/status/200", :content => "some text not in the response")
      check.should_not be_available
    end

    it "is true when response is any 200 level response" do
      check = IPVSLitmus::Dependency::HTTP.new("#{@url}/status/201")
      check.should be_available
      check = IPVSLitmus::Dependency::HTTP.new("#{@url}/status/202")
      check.should be_available
    end

    it "is false when response is 500 " do
      check = IPVSLitmus::Dependency::HTTP.new("#{@url}/status/500")
      check.should_not be_available
    end

    it "is false when the response is 404" do
      check = IPVSLitmus::Dependency::HTTP.new("#{@url}/status/404")
      check.should_not be_available
    end

    it "is false when the dependency is not available" do
      check = IPVSLitmus::Dependency::HTTP.new('http://127.0.0.1:7777')
      check.should_not be_available
    end
  end

  describe "to_s" do
    it "is the name of the class and the url" do
      check = IPVSLitmus::Dependency::HTTP.new("#{@url}/status/500")
      check.to_s.should == "Dependency::HTTP(http://127.0.0.1:9294/status/500)"
    end
  end
end
