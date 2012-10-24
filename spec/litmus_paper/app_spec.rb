require 'spec_helper'

describe LitmusPaper::App do
  def app
    LitmusPaper::App
  end

  before :each do
    LitmusPaper.configure(TEST_CONFIG)
  end

  describe "GET /" do
    it "returns the list of services litmus monitors" do
      LitmusPaper.services['test'] = LitmusPaper::Service.new('test')
      LitmusPaper.services['another'] = LitmusPaper::Service.new('another')

      get "/"

      last_response.status.should == 200
      last_response.body.should include('test')
      last_response.body.should include('another')
    end

    it "includes the litmus version" do
      get "/"

      last_response.status.should == 200
      last_response.body.should include("Litmus Paper #{LitmusPaper::VERSION}")
    end

    it "includes the health of the service" do
      LitmusPaper.services['test'] = LitmusPaper::Service.new('test')
      LitmusPaper.services['another'] = LitmusPaper::Service.new('another')

      get "/"

      last_response.status.should == 200
      last_response.body.should include("* test (0)\n")
    end

    it "includes the status if forced" do
      LitmusPaper.services['test'] = LitmusPaper::Service.new('test')
      LitmusPaper.services['another'] = LitmusPaper::Service.new('another')

      LitmusPaper::StatusFile.service_up_file("test").create("Up for testing")
      LitmusPaper::StatusFile.service_down_file("another").create("Down for testing")

      get "/"

      last_response.status.should == 200
      last_response.body.should include("* another (0) - forced: Down for testing\n")
      last_response.body.should include("* test (100) - forced: Up for testing\n")
    end
  end

  describe "POST /up" do
    it "creates a global upfile" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/up", :reason => "up for testing"
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 200
      last_response.body.should match(/up for testing/)
    end
  end

  describe "POST /down" do
    it "creates a global downfile" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/down", :reason => "down for testing"
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 503
      last_response.body.should match(/down for testing/)
    end
  end

  describe "POST /:service/up" do
    it "creates a service specific upfile" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/test/up", :reason => "up for testing"
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 200
      last_response.body.should match(/up for testing/)
    end
  end

  describe "DELETE /up" do
    it "removes the global upfile" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/up", :reason => "up for testing"
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 200

      delete "/up"
      last_response.status.should == 200

      get "/test/status"
      last_response.status.should == 503
      last_response.body.should_not match(/up for testing/)
    end

    it "404s if there is no upfile" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])

      delete "/up"

      last_response.status.should == 404
    end
  end

  describe "DELETE /down" do
    it "removes the global downfile" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/down", :reason => "down for testing"
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 503

      delete "/down"
      last_response.status.should == 200

      get "/test/status"
      last_response.should be_ok
      last_response.body.should_not match(/down for testing/)
    end
  end

  describe "DELETE /:service/up" do
    it "removes a service specific upfile" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/test/up", :reason => "up for testing"
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 200
      last_response.body.should match(/up for testing/)

      delete "/test/up"
      last_response.status.should == 200

      get "/test/status"
      last_response.status.should == 503
    end
  end

  describe "GET /:service/status" do
    it "is successful when the service is passing" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      get "/test/status"

      last_response.should be_ok
      last_response.header["Content-Type"].should == "text/plain"
      last_response.header["X-Health"].should == "100"
      last_response.header.should_not have_key("X-Health-Forced")
      last_response.body.should match(/Health: 100/)
      last_response.body.should match(/AlwaysAvailableDependency: OK/)
      last_response.body.should include("ConstantMetric(100): 100")
    end

    it "is 'service unavailable' when the check fails" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      get "/test/status"

      last_response.status.should == 503
      last_response.header["Content-Type"].should == "text/plain"
      last_response.header["X-Health"].should == "0"
      last_response.body.should match(/Health: 0/)
    end

    it "is 'not found' when the service is unknown" do
      get "/unknown/status"

      last_response.status.should == 404
      last_response.header["Content-Type"].should == "text/plain"
    end

    it "is 'service unavailable' when an up file and down file exists" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      LitmusPaper::StatusFile.service_up_file("test").create("Up for testing")
      LitmusPaper::StatusFile.service_down_file("test").create("Down for testing")

      get "/test/status"

      last_response.status.should == 503
      last_response.headers["X-Health-Forced"].should == "down"
      last_response.body.should match(/Down for testing/)
    end

    it "is 'service available' when an up file exists" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      LitmusPaper::StatusFile.service_up_file("test").create("Up for testing")

      get "/test/status"

      last_response.status.should == 200
      last_response.headers["X-Health-Forced"].should == "up"
      last_response.body.should match(/Up for testing/)
    end

    it "is 'service available' when an up file exists" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      LitmusPaper::StatusFile.service_up_file("test").create("Up for testing")

      get "/test/status"

      last_response.status.should == 200
      last_response.headers["X-Health-Forced"].should == "up"
      last_response.body.should match(/Up for testing/)
    end

    it "is 'service unavailable' when a global down file and up file exists" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      LitmusPaper::StatusFile.global_down_file.create("Down for testing")
      LitmusPaper::StatusFile.global_up_file.create("Up for testing")

      get "/test/status"

      last_response.status.should == 503
      last_response.headers["X-Health-Forced"].should == "down"
      last_response.body.should match(/Down for testing/)
    end

    it "is 'service unavailable' when a global down file exists" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      LitmusPaper::StatusFile.global_down_file.create("Down for testing")

      get "/test/status"

      last_response.status.should == 503
      last_response.headers["X-Health-Forced"].should == "down"
      last_response.body.should match(/Down for testing/)
    end

    it "is successful when a global up file exists" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      LitmusPaper::StatusFile.global_up_file.create("Up for testing")

      get "/test/status"

      last_response.status.should == 200
      last_response.headers["X-Health-Forced"].should == "up"
      last_response.body.should match(/Up for testing/)
    end

    it "resets the Facter cache" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      get "/test/status"
      last_response.should be_ok

      facter_uptime = Facter.value("uptime_seconds")
      sleep 1

      get "/test/status"
      last_response.should be_ok

      Facter.value("uptime_seconds").should > facter_uptime
    end
  end

  describe "server errors" do
    it "responds with a text/plain 500 response" do
      old_environment = :test
      begin
        app.environment = :production
        get "/test/error"
        last_response.status.should == 500
        last_response.headers["Content-Type"].should == "text/plain"
        last_response.body.should == "Server Error"
      ensure
        app.environment = old_environment
      end
    end
  end
end
