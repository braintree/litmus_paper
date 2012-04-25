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

    it "includes the health of individual checks" do
      health = IPVSLitmus::Health.new
      health.perform(ConstantMetric.new(12))
      health.perform(ConstantMetric.new(34))

      health.summary.should match(/ConstantMetric: 12/)
      health.summary.should match(/ConstantMetric: 34/)
    end

    it "only runs each dependency and check once" do
      pending("NYI")
    end
  end
end
