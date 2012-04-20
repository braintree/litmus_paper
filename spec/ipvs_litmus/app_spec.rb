require 'spec_helper'

describe IPVSLitmus::App do
  def app
    IPVSLitmus::App
  end

  describe "GET /status" do
    it "works" do
      get "/status"
      last_response.should be_ok
    end
  end

  describe "GET /:service/status" do
    it "is successful when the service is passing" do
      IPVSLitmus.services['test'] = AlwaysSuccessCheck.new
      get "/test/status"
      last_response.should be_ok
    end

    it "is 'service unavailable' when the check fails" do
      IPVSLitmus.services['test'] = AlwaysFailCheck.new
      get "/test/status"
      last_response.status.should == 503
    end

    it "is 'not found' when the service is unknown" do
      get "/unknown/status"
      last_response.status.should == 404
    end
  end
end
