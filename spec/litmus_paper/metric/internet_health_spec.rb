require 'spec_helper'

describe LitmusPaper::Dependency::TCP do

  describe "#current_health" do
    before(:all) do
      @server_3000 = TCPServer.new 3000
      @server_3001 = TCPServer.new 3001
      @server_3002 = TCPServer.new 3002
      @server_3003 = TCPServer.new 3003
      @server_3004 = TCPServer.new 3004
    end

    after(:all) do
      @server_3000.close
      @server_3001.close
      @server_3002.close
      @server_3003.close
      @server_3004.close
    end

    it "returns 100 when it's able to reach a single host" do
      internet_health = LitmusPaper::Metric::InternetHealth.new(100, ["127.0.0.1:3000"])
      expect(internet_health.current_health).to eq(100)
    end

    it "returns 0 when it's unable to reach a single host" do
      internet_health = LitmusPaper::Metric::InternetHealth.new(100, ["127.0.0.1:6000"])
      expect(internet_health.current_health).to eq(0)
    end

    it "returns 0 when it's request to a single host times out" do
      allow(TCPSocket).to receive(:new) do
        sleep(5)
      end
      internet_health = LitmusPaper::Metric::InternetHealth.new(
        100,
        ["127.0.0.1:6000"],
        { :timeout_seconds => 2 },
      )
      expect(internet_health.current_health).to eq(0)
    end

    it "returns 100 when it's able to reach multiple hosts" do
      internet_health = LitmusPaper::Metric::InternetHealth.new(
        100,
        [
          "127.0.0.1:3000",
          "127.0.0.1:3001",
          "127.0.0.1:3002",
          "127.0.0.1:3003",
          "127.0.0.1:3004",
        ],
      )
      expect(internet_health.current_health).to eq(100)
    end

    it "returns 50 when it's unable to reach half the hosts" do
      internet_health = LitmusPaper::Metric::InternetHealth.new(
        100,
        [
          "127.0.0.1:3000",
          "127.0.0.1:3001",
          "127.0.0.1:6002",
          "127.0.0.1:6003",
        ],
      )
      expect(internet_health.current_health).to eq(50)
    end

    it "returns 50 when it's request to a single host out of two hosts times out" do
      allow(TCPSocket).to receive(:new) do
        allow(TCPSocket).to receive(:new).and_call_original
        sleep(5)
      end
      internet_health = LitmusPaper::Metric::InternetHealth.new(
        100,
        ["127.0.0.1:3000", "127.0.0.1:3001"],
        { :timeout_seconds => 2 },
      )
      expect(internet_health.current_health).to eq(50)
    end

    it "returns 0 when it's unable to reach any of the hosts" do
      internet_health = LitmusPaper::Metric::InternetHealth.new(
        100,
        [
          "127.0.0.1:6000",
          "127.0.0.1:6001",
          "127.0.0.1:6002",
          "127.0.0.1:6003",
          "127.0.0.1:6004",
        ],
      )
      expect(internet_health.current_health).to eq(0)
    end

    it "logs exceptions and returns 0" do
      internet_health = LitmusPaper::Metric::InternetHealth.new(100, ["127.0.0.1:6000"])
      expect(LitmusPaper.logger).to receive(:info)
      expect(internet_health.current_health).to eq(0)
    end
  end

  describe "to_s" do
    it "is the name of the class and the lists of hosts" do
      internet_health = LitmusPaper::Metric::InternetHealth.new(
        100,
        [
          "127.0.0.1:6000",
          "127.0.0.1:6001",
          "127.0.0.1:6002",
          "127.0.0.1:6003",
          "127.0.0.1:6004",
        ],
      )
      expect(internet_health.to_s).to eq("Metric::InternetHealth(100, [\"127.0.0.1:6000\", \"127.0.0.1:6001\", \"127.0.0.1:6002\", \"127.0.0.1:6003\", \"127.0.0.1:6004\"], {})")
    end
  end

end
