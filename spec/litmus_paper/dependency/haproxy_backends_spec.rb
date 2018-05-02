require 'spec_helper'

describe LitmusPaper::Dependency::HaproxyBackends do
  describe "available?" do
    before(:each) do
      FileUtils.rm_rf("/tmp/stub-haproxy-stats")
      system "spec/support/haproxy_test_socket /tmp/stub-haproxy-stats &"
      sleep 1
    end

    it "is available if at least one backend is up" do
      haproxy = LitmusPaper::Dependency::HaproxyBackends.new("/tmp/stub-haproxy-stats", "yellow_cluster")
      haproxy.should be_available
    end

    it "returns false if no nodes are available" do
      haproxy = LitmusPaper::Dependency::HaproxyBackends.new("/tmp/stub-haproxy-stats", "orange_cluster")
      haproxy.should_not be_available
    end

    it "logs exceptions and returns false" do
      haproxy = LitmusPaper::Dependency::HaproxyBackends.new("/dev/null", "yellow_cluster")
      LitmusPaper.logger.should_receive(:info)
      haproxy.should_not be_available
    end
  end

  describe "average_weight" do
    before(:each) do
      FileUtils.rm_rf("/tmp/stub-haproxy-stats")
      system "spec/support/haproxy_test_socket /tmp/stub-haproxy-stats &"
      sleep 1
    end

    it "returns average weight if at least one backend is up" do
      haproxy = LitmusPaper::Dependency::HaproxyBackends.new("/tmp/stub-haproxy-stats", "yellow_cluster")
      haproxy.average_weight.should_be 90
    end

    it "returns 0 if no nodes are available" do
      haproxy = LitmusPaper::Dependency::HaproxyBackends.new("/tmp/stub-haproxy-stats", "orange_cluster")
      haproxy.average_weight.should_be 0
    end

    it "logs exceptions and returns false" do
      haproxy = LitmusPaper::Dependency::HaproxyBackends.new("/dev/null", "yellow_cluster")
      LitmusPaper.logger.should_receive(:info)
      haproxy.should_not be_available
    end
  end

  describe "timeouts" do
    before(:each) do
      FileUtils.rm_rf("/tmp/stub-haproxy-stats")
      system "spec/support/haproxy_test_socket /tmp/stub-haproxy-stats 3 &"
      sleep 1
    end

    it "returns false after a configurable number of seconds" do
      haproxy = LitmusPaper::Dependency::HaproxyBackends.new("/tmp/stub-haproxy-stats", "yellow_cluster", :timeout_seconds => 1)
      haproxy.should_not be_available
    end
  end

  describe "to_s" do
    it "includes the socket file and the cluster" do
      haproxy = LitmusPaper::Dependency::HaproxyBackends.new("/tmp/stub-haproxy-stats", "orange_cluster")
      haproxy.to_s.should == 'Dependency::HaproxyBackends(/tmp/stub-haproxy-stats, orange_cluster)'
    end
  end
end

