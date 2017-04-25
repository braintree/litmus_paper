require 'spec_helper'

describe LitmusPaper::Dependency::TCP do
  describe "accepts input data and compares result against an expected output " do
    before(:each) do
      @server = TCPServer.new 7333
      @thread = Thread.start do
        s = @server.accept
        s.puts "+PONG"
      end
    end

    after(:each) do
      @server.close
      @thread.join
    end

    describe "#available?" do
      it "is true when expected_output equals response from socket" do
        check = LitmusPaper::Dependency::TCP.new("127.0.0.1", 7333, :expected_output => "+PONG", :input_data => "PING")
        expect(check).to be_available
      end

      it "is true when expected_output equals response from socket when no input is supplied" do
        check = LitmusPaper::Dependency::TCP.new("127.0.0.1", 7333, :expected_output => "+PONG")
        expect(check).to be_available
      end

      it "is false when expected_output does not equal response from socket" do
        check = LitmusPaper::Dependency::TCP.new("127.0.0.1", 7333, :expected_output => "+PANG", :input_data => "PING")
        expect(check).not_to be_available
      end
    end
  end

  describe "#available?" do
    before(:all) do
      @server = TCPServer.new 3333
    end

    after(:all) do
      @server.close
    end

    it "is true when it's able to reach the ip and port" do
      check = LitmusPaper::Dependency::TCP.new("127.0.0.1", 3333)
      expect(check).to be_available
    end

    it "is false when the ip is not available" do
      check = LitmusPaper::Dependency::TCP.new("10.254.254.254", 3333)
      expect(check).not_to be_available
    end

    it "is false when the port is not available" do
      check = LitmusPaper::Dependency::TCP.new("127.0.0.1", 3334)
      expect(check).not_to be_available
    end

    it "is false when the request times out" do
      allow(TCPSocket).to receive(:new) do
        sleep(5)
      end
      check = LitmusPaper::Dependency::TCP.new("127.0.0.1", 3334, :timeout_seconds => 1)
      expect(check).not_to be_available
    end

    it "logs exceptions and returns false" do
      check = LitmusPaper::Dependency::TCP.new("127.0.0.1", 3334)
      expect(LitmusPaper.logger).to receive(:info)
      expect(check).not_to be_available
    end
  end

  describe "to_s" do
    it "is the name of the class and the ip and port" do
      check = LitmusPaper::Dependency::TCP.new("127.0.0.1", 3333)
      expect(check.to_s).to eq("Dependency::TCP(tcp://127.0.0.1:3333)")
    end
  end
end
