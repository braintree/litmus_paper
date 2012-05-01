require 'spec_helper'

describe IPVSLitmus::App do
  def app
    IPVSLitmus::App
  end

  describe "POST /up" do
    it "creates a global upfile" do
      test_service = IPVSLitmus::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      post "/up", :reason => "up for testing"
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 200
      last_response.body.should match(/up for testing/)
    end
  end

  describe "DELETE /up" do
    it "removes the global upfile" do
      test_service = IPVSLitmus::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

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
      test_service = IPVSLitmus::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])

      delete "/up"

      last_response.status.should == 404
    end
  end

  describe "POST /down" do
    it "creates a global downfile" do
      test_service = IPVSLitmus::Service.new('test', [AlwaysAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      post "/down", :reason => "down for testing"
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 503
      last_response.body.should match(/down for testing/)
    end
  end

  describe "DELETE /down" do
    it "removes the global downfile" do
      test_service = IPVSLitmus::Service.new('test', [AlwaysAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

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

    it "404s if there is no downfile" do
      test_service = IPVSLitmus::Service.new('test', [AlwaysAvailableDependency.new], [ConstantMetric.new(100)])

      delete "/down"

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
      last_response.body.should match(/Health: 100/)
      last_response.body.should match(/AlwaysAvailableDependency: OK/)
      last_response.body.should match(/ConstantMetric: 100/)
    end

    it "is 'service unavailable' when the check fails" do
      test_service = IPVSLitmus::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      get "/test/status"

      last_response.status.should == 503
      last_response.header["Content-Type"].should == "text/plain"
    end

    it "is 'not found' when the service is unknown" do
      get "/unknown/status"

      last_response.status.should == 404
      last_response.header["Content-Type"].should == "text/plain"
    end

    it "is 'service unavailable' when an up file and down file exists" do
      test_service = IPVSLitmus::Service.new('test', [AlwaysAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      write_up_file "test", "Up for testing"
      write_down_file "test", "Down for testing"

      get "/test/status"

      last_response.status.should == 503
      last_response.body.should match(/Down for testing/)
    end

    it "is 'service available' when an up file exists" do
      test_service = IPVSLitmus::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      write_up_file "test", "Up for testing"

      get "/test/status"

      last_response.status.should == 200
      last_response.body.should match(/Up for testing/)
    end

    it "is 'service available' when an up file exists" do
      test_service = IPVSLitmus::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      write_up_file "test", "Up for testing"

      get "/test/status"

      last_response.status.should == 200
      last_response.body.should match(/Up for testing/)
    end

    it "is 'service unavailable' when a global down file and up file exists" do
      test_service = IPVSLitmus::Service.new('test', [AlwaysAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      write_global_down_file "Down for testing"
      write_global_up_file "Up for testing"

      get "/test/status"

      last_response.status.should == 503
      last_response.body.should match(/Down for testing/)
    end

    it "is 'service unavailable' when a global down file exists" do
      test_service = IPVSLitmus::Service.new('test', [AlwaysAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      write_global_down_file "Down for testing"

      get "/test/status"

      last_response.status.should == 503
      last_response.body.should match(/Down for testing/)
    end

    it "is successful when a global up file exists" do
      test_service = IPVSLitmus::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(100)])
      IPVSLitmus.services['test'] = test_service

      write_global_up_file "Up for testing"

      get "/test/status"

      last_response.status.should == 200
      last_response.body.should match(/Up for testing/)
    end
  end
end
