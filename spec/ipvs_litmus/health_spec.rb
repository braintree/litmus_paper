require 'spec_helper'

describe IPVSLitmus::Health do
  describe "ok?" do
    it "is true when health is greater than 0" do
      health = IPVSLitmus::Health.new
      health.perform(ConstantMetric.new(50))
      health.should be_ok
    end

    it "is false when health is 0" do
      health = IPVSLitmus::Health.new
      health.perform(ConstantMetric.new(0))
      health.should_not be_ok
    end
  end

  describe "perform" do
    it "executes the check and adds its value to its health" do
      health = IPVSLitmus::Health.new
      health.perform(ConstantMetric.new(50))
      health.perform(ConstantMetric.new(25))
      health.value.should == 75
    end
  end

  describe "ensure" do
    it "checks the dependency and modifies the value accordingly" do
      health = IPVSLitmus::Health.new
      health.ensure(NeverAvailableDependency.new)
      health.perform(ConstantMetric.new(50))
      health.value.should == 0
    end
  end

  describe "summary" do
    it "includes the availablilty of dependencies" do
      health = IPVSLitmus::Health.new
      health.ensure(NeverAvailableDependency.new)
      health.ensure(AlwaysAvailableDependency.new)

      health.summary.should match(/NeverAvailableDependency: FAIL/)
      health.summary.should match(/AlwaysAvailableDependency: OK/)
    end

    it "includes the health of individual metrics" do
      health = IPVSLitmus::Health.new
      health.perform(ConstantMetric.new(12))
      health.perform(ConstantMetric.new(34))

      health.summary.should include("ConstantMetric(12): 12")
      health.summary.should include("ConstantMetric(34): 34")
    end

    it "only runs each metric once" do
      health = IPVSLitmus::Health.new
      metric = ConstantMetric.new(12)
      metric.should_receive(:current_health).once.and_return(12)

      health.perform(metric)
    end

    it "only runs each dependency once" do
      health = IPVSLitmus::Health.new
      dependency = AlwaysAvailableDependency.new
      dependency.should_receive(:available?).once.and_return(true)

      health.ensure(dependency)
    end
  end
end
