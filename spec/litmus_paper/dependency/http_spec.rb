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
      before do
        `env SSL_TEST_PORT=9295 PID_FILE=/tmp/https-test-server.pid bundle exec spec/script/https_test_server.rb`
        SpecHelper.wait_for_service :host => '127.0.0.1', :port => 9295
      end

      after do
        system "kill -9 `cat /tmp/https-test-server.pid`"
      end

      it "can make https request" do
        check = LitmusPaper::Dependency::HTTP.new(
          "https://127.0.0.1:9295",
          :ca_file => TEST_CA_CERT
        )
        check.should be_available
      end

      it "is not available when SSL verification fails" do
        check = LitmusPaper::Dependency::HTTP.new(
          "https://127.0.0.1:9295",
          :ca_file => nil
        )
        check.should_not be_available
      end
    end

    context "basic auth" do
      it "uses the basic auth credentials provided in the URL" do
        check = LitmusPaper::Dependency::HTTP.new("http://admin:admin@127.0.0.1:9294/basic_auth")
        check.should be_available
      end

      it "works with blank password" do
        check = LitmusPaper::Dependency::HTTP.new("http://justadmin:@127.0.0.1:9294/basic_auth_without_password")
        check.should be_available
      end

      it "works with blank user" do
        check = LitmusPaper::Dependency::HTTP.new("http://:justpassword@127.0.0.1:9294/basic_auth_without_user")
        check.should be_available
      end
    end

    context "special characters in path" do
      it "works with a URI encoded slash" do
        check = LitmusPaper::Dependency::HTTP.new("http://admin:admin@127.0.0.1:9294/return_next_path_segment/%2F", :content => '/')
        check.should be_available
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

    it "is false when the request times out" do
      check = LitmusPaper::Dependency::HTTP.new("#{@url}/sleep/2", :timeout_seconds => 1)
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
