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
      expect(haproxy).to be_available
    end

    it "returns false if no nodes are available" do
      haproxy = LitmusPaper::Dependency::HaproxyBackends.new("/tmp/stub-haproxy-stats", "orange_cluster")
      expect(haproxy).not_to be_available
    end

    it "logs exceptions and returns false" do
      haproxy = LitmusPaper::Dependency::HaproxyBackends.new("/dev/null", "yellow_cluster")
      expect(LitmusPaper.logger).to receive(:info)
      expect(haproxy).not_to be_available
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
      expect(haproxy).not_to be_available
    end
  end

  describe "to_s" do
    it "includes the socket file and the cluster" do
      haproxy = LitmusPaper::Dependency::HaproxyBackends.new("/tmp/stub-haproxy-stats", "orange_cluster")
      expect(haproxy.to_s).to eq('Dependency::HaproxyBackends(/tmp/stub-haproxy-stats, orange_cluster)')
    end
  end
end

