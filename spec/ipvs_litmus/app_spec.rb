require 'spec_helper'

describe IpvsLitmus::App do
  def app
    IpvsLitmus::App
  end

  describe "GET /status" do
    it "works" do
      get "/status"
      last_response.should be_ok
    end
  end
end
