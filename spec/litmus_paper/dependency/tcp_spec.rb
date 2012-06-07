require 'spec_helper'

describe LitmusPaper::Dependency::TCP do
  run_in_reactor

  describe "#available?" do
    around(:each) do |spec|
      begin
        @server = EM.start_server('127.0.0.1', 3333)
        spec.run
      ensure
        EM.stop_server @server if @server
      end
    end
    it "is true when it's able to reach the ip and port" do
      check = LitmusPaper::Dependency::TCP.new("127.0.0.1", 3333)
      check.should be_available
    end

    it "is false when the ip is not available" do
      check = LitmusPaper::Dependency::TCP.new("127.1.1.15", 3333, :timeout => 0.3)
      check.should_not be_available
    end

    it "is false when the port is not available" do
      check = LitmusPaper::Dependency::TCP.new("127.0.0.1", 3334, :timeout => 0.3)
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
