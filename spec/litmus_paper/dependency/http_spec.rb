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
    context "http" do
      it "uses the given http method when making the request" do
        check = LitmusPaper::Dependency::HTTP.new("#{@url}/method", :method => "GET", :content => "POST")
        expect(check).not_to be_available

        check = LitmusPaper::Dependency::HTTP.new("#{@url}/method", :method => "POST", :content => "POST")
        expect(check).to be_available
      end

      it "sends an accept header" do
        check = LitmusPaper::Dependency::HTTP.new("#{@url}/echo_accept", :method => "GET", :content => Regexp.escape("*/*"))
        expect(check).to be_available
      end

      it "sends a user agent" do
        check = LitmusPaper::Dependency::HTTP.new("#{@url}/echo_agent", :method => "GET", :content => "Litmus Paper")
        expect(check).to be_available
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
        expect(check).to be_available
      end

      it "is not available when SSL verification fails" do
        check = LitmusPaper::Dependency::HTTP.new(
          "https://127.0.0.1:9295",
          :ca_file => nil
        )
        expect(check).not_to be_available
      end
    end

    context "basic auth" do
      it "uses the basic auth credentials provided in the URL" do
        check = LitmusPaper::Dependency::HTTP.new("http://admin:admin@127.0.0.1:9294/basic_auth")
        expect(check).to be_available
      end

      it "works with blank password" do
        check = LitmusPaper::Dependency::HTTP.new("http://justadmin:@127.0.0.1:9294/basic_auth_without_password")
        expect(check).to be_available
      end

      it "works with blank user" do
        check = LitmusPaper::Dependency::HTTP.new("http://:justpassword@127.0.0.1:9294/basic_auth_without_user")
        expect(check).to be_available
      end
    end

    context "special characters in path" do
      it "works with a URI encoded slash" do
        check = LitmusPaper::Dependency::HTTP.new("http://admin:admin@127.0.0.1:9294/return_next_path_segment/%2F", :content => '/')
        expect(check).to be_available
      end
    end

    it "is true when response is 200" do
      check = LitmusPaper::Dependency::HTTP.new("#{@url}/status/200")
      expect(check).to be_available
    end

    it "is true when response is 200 and expected content matches" do
      check = LitmusPaper::Dependency::HTTP.new("#{@url}/status/200", :content => "200 OK")
      expect(check).to be_available
    end

    it "is false when response is 200, but does not match content" do
      check = LitmusPaper::Dependency::HTTP.new("#{@url}/status/200", :content => "some text not in the response")
      expect(check).not_to be_available
    end

    it "is true when response is any 200 level response" do
      check = LitmusPaper::Dependency::HTTP.new("#{@url}/status/201")
      expect(check).to be_available
      check = LitmusPaper::Dependency::HTTP.new("#{@url}/status/202")
      expect(check).to be_available
    end

    it "is false when response is 500 " do
      check = LitmusPaper::Dependency::HTTP.new("#{@url}/status/500")
      expect(check).not_to be_available
    end

    it "is false when the response is 404" do
      check = LitmusPaper::Dependency::HTTP.new("#{@url}/status/404")
      expect(check).not_to be_available
    end

    it "is false when the dependency is not available" do
      check = LitmusPaper::Dependency::HTTP.new('http://127.0.0.1:7777')
      expect(check).not_to be_available
    end

    it "is false when the request times out" do
      check = LitmusPaper::Dependency::HTTP.new("#{@url}/sleep/2", :timeout_seconds => 1)
      expect(check).not_to be_available
    end

    it "logs exceptions and returns false" do
      check = LitmusPaper::Dependency::HTTP.new('http://127.0.0.1:7777')
      expect(LitmusPaper.logger).to receive(:info)
      expect(check).not_to be_available
    end
  end

  describe "to_s" do
    it "is the name of the class and the url" do
      check = LitmusPaper::Dependency::HTTP.new("#{@url}/status/500")
      expect(check.to_s).to eq("Dependency::HTTP(http://127.0.0.1:9294/status/500)")
    end
  end
end
