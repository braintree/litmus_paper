require 'spec_helper'

describe IPVSLitmus::App do
  def app
    IPVSLitmus::App
  end

  describe "GET /" do
    it "returns the list of services litmus monitors" do
      IPVSLitmus.services['test'] = IPVSLitmus::Service.new('test')
      IPVSLitmus.services['another'] = IPVSLitmus::Service.new('another')

      get "/"

      last_response.status.should == 200
      last_response.body.should include('test')
      last_response.body.should include('another')
    end
  end

  describe "POST /force/*" do
    it "creates a global upfile" do
      test_service = IPVSLitmus::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      post "/force/up", :reason => "up for testing"
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 200
      last_response.body.should match(/up for testing/)
    end

    it "creates a global downfile" do
      test_service = IPVSLitmus::Service.new('test', [AlwaysAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      post "/force/down", :reason => "down for testing"
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 503
      last_response.body.should match(/down for testing/)
    end

    it "creates a service specific upfile" do
      test_service = IPVSLitmus::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      post "/force/up/test", :reason => "up for testing"
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 200
      last_response.body.should match(/up for testing/)
    end
  end

  describe "DELETE /force/*" do
    it "removes the global upfile" do
      test_service = IPVSLitmus::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      post "/force/up", :reason => "up for testing"
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 200

      delete "/force/up"
      last_response.status.should == 200

      get "/test/status"
      last_response.status.should == 503
      last_response.body.should_not match(/up for testing/)
    end

    it "removes the global downfile" do
      test_service = IPVSLitmus::Service.new('test', [AlwaysAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      post "/force/down", :reason => "down for testing"
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 503

      delete "/force/down"
      last_response.status.should == 200

      get "/test/status"
      last_response.should be_ok
      last_response.body.should_not match(/down for testing/)
    end

    it "removes a service specific upfile" do
      test_service = IPVSLitmus::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      post "/force/up/test", :reason => "up for testing"
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 200
      last_response.body.should match(/up for testing/)

      delete "/force/up/test"
      last_response.status.should == 200

      get "/test/status"
      last_response.status.should == 503
    end

    it "404s if there is no upfile" do
      test_service = IPVSLitmus::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])

      delete "/up"

      last_response.status.should == 404
    end
  end

  describe "GET /:service/status" do
    it "is successful when the service is passing" do
      test_service = IPVSLitmus::Service.new('test', [AlwaysAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      get "/test/status"

      last_response.should be_ok
      last_response.header["Content-Type"].should == "text/plain"
      last_response.header["X-Health"].should == "100"
      last_response.body.should match(/Health: 100/)
      last_response.body.should match(/AlwaysAvailableDependency: OK/)
      last_response.body.should include("ConstantMetric(100): 100")
    end

    it "is 'service unavailable' when the check fails" do
      test_service = IPVSLitmus::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

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
      test_service = IPVSLitmus::Service.new('test', [AlwaysAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      IPVSLitmus::StatusFile.new("up", "test").create("Up for testing")
      IPVSLitmus::StatusFile.new("down", "test").create("Down for testing")

      get "/test/status"

      last_response.status.should == 503
      last_response.body.should match(/Down for testing/)
    end

    it "is 'service available' when an up file exists" do
      test_service = IPVSLitmus::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      IPVSLitmus::StatusFile.new("up", "test").create("Up for testing")

      get "/test/status"

      last_response.status.should == 200
      last_response.body.should match(/Up for testing/)
    end

    it "is 'service available' when an up file exists" do
      test_service = IPVSLitmus::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      IPVSLitmus::StatusFile.new("up", "test").create("Up for testing")

      get "/test/status"

      last_response.status.should == 200
      last_response.body.should match(/Up for testing/)
    end

    it "is 'service unavailable' when a global down file and up file exists" do
      test_service = IPVSLitmus::Service.new('test', [AlwaysAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      IPVSLitmus::StatusFile.new("global_down").create("Down for testing")
      IPVSLitmus::StatusFile.new("global_up").create("Up for testing")

      get "/test/status"

      last_response.status.should == 503
      last_response.body.should match(/Down for testing/)
    end

    it "is 'service unavailable' when a global down file exists" do
      test_service = IPVSLitmus::Service.new('test', [AlwaysAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      IPVSLitmus::StatusFile.new("global_down").create("Down for testing")

      get "/test/status"

      last_response.status.should == 503
      last_response.body.should match(/Down for testing/)
    end

    it "is successful when a global up file exists" do
      test_service = IPVSLitmus::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      IPVSLitmus::StatusFile.new("global_up").create("Up for testing")

      get "/test/status"

      last_response.status.should == 200
      last_response.body.should match(/Up for testing/)
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
