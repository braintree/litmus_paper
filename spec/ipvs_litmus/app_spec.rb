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
end
