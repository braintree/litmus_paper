require 'spec_helper'

describe LitmusPaper::Metric::HaproxyWeight do
  describe "#current_health" do
    it "is the value of the average weight" do
      LitmusPaper::Dependency::HaproxyBackends.any_instance.stub(
        :average_weight => 4,
      )
      metric = LitmusPaper::Metric::HaproxyWeight.new("socket", "cluster")
      metric.current_health.should == 4
    end
  end

  describe "#to_s" do
    it "is the check name and the weight" do
      always_healthy = LitmusPaper::Metric::HaproxyWeight.new("socket", "cluster")
      always_healthy.to_s.should == "Metric::HaproxyWeight(Dependency::HaproxyBackends(socket, cluster))"
    end
  end
end