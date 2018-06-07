require 'spec_helper'

describe LitmusPaper::Metric::HaproxyBackendsHealth do
  describe "#current_health" do
    before(:each) do
      FileUtils.rm_rf("/tmp/stub-haproxy-stats")
      system "spec/support/haproxy_test_socket /tmp/stub-haproxy-stats &"
      sleep 1
    end

    it "should report as 33 if 2/3 of the nodes are down (yellow cluster)" do
      health = LitmusPaper::Metric::HaproxyBackendsHealth.new("/tmp/stub-haproxy-stats", "yellow_cluster")
      health.current_health.should == 33
    end


    it "should report as 0 if all of the nodes are down (orange cluster)" do
      health = LitmusPaper::Metric::HaproxyBackendsHealth.new("/tmp/stub-haproxy-stats", "orange_cluster")
      health.current_health.should == 0
    end

    it "should report as 100 if all of the nodes are up (green cluster)" do
      health = LitmusPaper::Metric::HaproxyBackendsHealth.new("/tmp/stub-haproxy-stats", "green_cluster")
      health.current_health.should == 100
    end
  end

  describe "#to_s" do
    it "is the name of the class and the cluster name " do
      metric = LitmusPaper::Metric::HaproxyBackendsHealth.new("/tmp/stub-haproxy-stats", "green_cluster")
      metric.to_s.should == "Metric::HaproxyBackendsHealth(green_cluster)"
    end
  end
end
