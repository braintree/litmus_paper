require 'spec_helper'

describe LitmusPaper::Dependency::HTTP do
  before(:all) do
    server_start = system "bundle exec rackup spec/support/http_test_server_config.ru --port 9294 --pid /tmp/http-test-server.pid --daemonize"
    SpecHelper.wait_for_service :host => '127.0.0.1', :port => 9294
    @url = "http://127.0.0.1:9294"
  end

  after(:all) do
    system "kill -9 `cat /tmp/http-test-server.pid`"
  end

  describe "#available?" do
    context "http method" do
      it "uses the given http method when making the request" do
        check = LitmusPaper::Dependency::HTTP.new("#{@url}/method", :method => "GET", :content => "POST")
        check.should_not be_available

        check = LitmusPaper::Dependency::HTTP.new("#{@url}/method", :method => "POST", :content => "POST")
        check.should be_available
      end
    end

    context "https" do
      it "can make https request" do
        begin
          output = `env SSL_TEST_PORT=9297 PID_FILE=/tmp/https-test-server.pid bundle exec spec/script/https_test_server.rb`
          unless $?.success?
            raise "failed to start test https server. exit code: #{$?.exitstatus}, output: #{output}"
          end
          SpecHelper.wait_for_service :host => '127.0.0.1', :port => 9297

          check = LitmusPaper::Dependency::HTTP.new(
            "https://localhost:9297/",
            :ca_file => TEST_CA_CERT
          )
          check.should be_available
        ensure
          system "kill -9 `cat /tmp/https-test-server.pid`"
        end
      end
    end

    it "is true when response is 200" do
      check = LitmusPaper::Dependency::HTTP.new("#{@url}/status/200")
      check.should be_available
    end

    it "is true when response is 200 and expected content matches" do
      check = LitmusPaper::Dependency::HTTP.new("#{@url}/status/200", :content => "200 OK")
      check.should be_available
    end

    it "is false when response is 200, but does not match content" do
      check = LitmusPaper::Dependency::HTTP.new("#{@url}/status/200", :content => "some text not in the response")
      check.should_not be_available
    end

    it "is true when response is any 200 level response" do
      check = LitmusPaper::Dependency::HTTP.new("#{@url}/status/201")
      check.should be_available
      check = LitmusPaper::Dependency::HTTP.new("#{@url}/status/202")
      check.should be_available
    end

    it "is false when response is 500 " do
      check = LitmusPaper::Dependency::HTTP.new("#{@url}/status/500")
      check.should_not be_available
    end

    it "is false when the response is 404" do
      check = LitmusPaper::Dependency::HTTP.new("#{@url}/status/404")
      check.should_not be_available
    end

    it "is false when the dependency is not available" do
      check = LitmusPaper::Dependency::HTTP.new('http://127.0.0.1:7777')
      check.should_not be_available
    end
  end

  describe "to_s" do
    it "is the name of the class and the url" do
      check = LitmusPaper::Dependency::HTTP.new("#{@url}/status/500")
      check.to_s.should == "Dependency::HTTP(http://127.0.0.1:9294/status/500)"
    end
  end
end
