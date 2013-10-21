require 'spec_helper'

describe LitmusPaper::Metric::ConstantMetric do
  describe "#current_health" do
    it "is the value of the weight" do
      always_healthy = LitmusPaper::Metric::ConstantMetric.new(100)
      always_healthy.current_health.should == 100
    end
  end

  describe "#to_s" do
    it "is the check name and the weight" do
      always_healthy = LitmusPaper::Metric::ConstantMetric.new(50)
      always_healthy.to_s.should == "Metric::ConstantMetric(50)"
    end
  end
end
