require 'spec_helper'

describe LitmusPaper::Metric::InternetHealth do

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
      internet_health.current_health.should == 100
    end

    it "returns 0 when it's unable to reach a single host" do
      internet_health = LitmusPaper::Metric::InternetHealth.new(100, ["127.0.0.1:6000"])
      internet_health.current_health.should == 0
    end

    it "returns 0 when it's request to a single host times out" do
      TCPSocket.stub(:new) do
        sleep(5)
      end
      internet_health = LitmusPaper::Metric::InternetHealth.new(
        100,
        ["127.0.0.1:6000"],
        { :timeout_seconds => 2 },
      )
      internet_health.current_health.should == 0
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
      internet_health.current_health.should == 100
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
      internet_health.current_health.should == 50
    end

    it "returns 50 when it's request to a single host out of two hosts times out" do
      TCPSocket.stub(:new) do
        TCPSocket.unstub(:new)
        sleep(5)
      end
      internet_health = LitmusPaper::Metric::InternetHealth.new(
        100,
        ["127.0.0.1:3000", "127.0.0.1:3001"],
        { :timeout_seconds => 2 },
      )
      internet_health.current_health.should == 50
    end

    it "returns 0 when it's unable to reach any of the hosts" do
      internet_health = LitmusPaper::Metric::InternetHealth.new(
        100,
        [
          "127.0.0.1:6002",
          "127.0.0.1:6003",
          "127.0.0.1:6004",
          "127.0.0.1:6005",
          "127.0.0.1:6006",
        ],
      )
      internet_health.current_health.should == 0
    end

    it "returns shortly after the timeout provided when all hosts timeout" do
      TCPSocket.stub(:new) do
        sleep(5)
      end
      internet_health = LitmusPaper::Metric::InternetHealth.new(
        100,
        ["127.0.0.1:6000",
        "127.0.0.1:6000",
        "127.0.0.1:6000",
        "127.0.0.1:6000"],
        { :timeout_seconds => 2 },
      )
      health = nil
      Timeout.timeout(3) do
        health = internet_health.current_health
      end
      health.should == 0
    end

    it "returns shortly after the timeout provided when one of many hosts timeout" do
      TCPSocket.stub(:new) do
        TCPSocket.unstub(:new)
        sleep(5)
      end
      internet_health = LitmusPaper::Metric::InternetHealth.new(
        100,
        ["127.0.0.1:6000",
        "127.0.0.1:6000",
        "127.0.0.1:6000",
        "127.0.0.1:6000"],
        { :timeout_seconds => 2 },
      )
      health = nil
      Timeout.timeout(3) do
        health = internet_health.current_health
      end
      health.should == 0
    end

    it "returns shortly after the timeout when one host times out" do
      TCPSocket.stub(:new) do
        sleep(5)
      end
      internet_health = LitmusPaper::Metric::InternetHealth.new(
        100,
        ["127.0.0.1:6000"],
        { :timeout_seconds => 2 },
      )
      health = nil
      Timeout.timeout(3) do
        health = internet_health.current_health
      end
      health.should == 0
    end

    it "logs exceptions and returns 0" do
      internet_health = LitmusPaper::Metric::InternetHealth.new(100, ["127.0.0.1:6000"])
      LitmusPaper.logger.should_receive(:info)
      internet_health.current_health.should == 0
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
      internet_health.to_s.should == "Metric::InternetHealth(100, [\"127.0.0.1:6000\", \"127.0.0.1:6001\", \"127.0.0.1:6002\", \"127.0.0.1:6003\", \"127.0.0.1:6004\"], {})"
    end
  end

end
