require 'spec_helper'

describe LitmusPaper::Metric::HaproxyWeightMetric do
  describe "#current_health" do
    it "is the value of the average weight" do
      LitmusPaper::Dependency::HaproxyBackends.any_instance.stub(
        :average_weight => 4,
      )
      haproxy_backends = LitmusPaper::Dependency::HaproxyBackends.new("socket", "cluster")
      metric = LitmusPaper::Metric::HaproxyWeightMetric.new(haproxy_backends)
      metric.current_health.should == 4
    end
  end

  describe "#to_s" do
    it "is the check name and the weight" do
      haproxy_backends = LitmusPaper::Dependency::HaproxyBackends.new("socket", "cluster")
      always_healthy = LitmusPaper::Metric::HaproxyWeightMetric.new(haproxy_backends)
      always_healthy.to_s.should == "Metric::HaproxyWeightMetric(Dependency::HaproxyBackends(socket, cluster))"
    end
  end
end
