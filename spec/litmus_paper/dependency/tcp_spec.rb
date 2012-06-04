require 'spec_helper'

describe LitmusPaper::Dependency::TCP do
  before(:all) do
    @server = TCPServer.new 3333
  end

  after(:all) do
    @server.close
  end

  describe "#available?" do
    it "is true when it's able to reach the ip and port" do
      check = LitmusPaper::Dependency::TCP.new("127.0.0.1", 3333)
      check.should be_available
    end

    it "is false when the ip is not available" do
      check = LitmusPaper::Dependency::TCP.new("10.254.254.254", 3333)
      check.should_not be_available
    end

    it "is false when the port is not available" do
      check = LitmusPaper::Dependency::TCP.new("127.0.0.1", 3334)
      check.should_not be_available
    end
  end

  describe "to_s" do
    it "is the name of the class and the ip and port" do
      check = LitmusPaper::Dependency::TCP.new("127.0.0.1", 3333)
      check.to_s.should == "Dependency::TCP(tcp://127.0.0.1:3333)"
    end
  end
end
