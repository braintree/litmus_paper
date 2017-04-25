require 'spec_helper'

describe LitmusPaper::Health do
  describe "ok?" do
    it "is true when health is greater than 0" do
      health = LitmusPaper::Health.new
      health.perform(LitmusPaper::Metric::ConstantMetric.new(50))
      expect(health).to be_ok
    end

    it "is false when health is 0" do
      health = LitmusPaper::Health.new
      health.perform(LitmusPaper::Metric::ConstantMetric.new(0))
      expect(health).not_to be_ok
    end
  end

  describe "perform" do
    it "executes the check and adds its value to its health" do
      health = LitmusPaper::Health.new
      health.perform(LitmusPaper::Metric::ConstantMetric.new(50))
      health.perform(LitmusPaper::Metric::ConstantMetric.new(25))
      expect(health.value).to eq(75)
    end
  end

  describe "ensure" do
    it "checks the dependency and modifies the value accordingly" do
      health = LitmusPaper::Health.new
      health.ensure(NeverAvailableDependency.new)
      health.perform(LitmusPaper::Metric::ConstantMetric.new(50))
      expect(health.value).to eq(0)
    end
  end

  describe "summary" do
    it "includes the availablilty of dependencies" do
      health = LitmusPaper::Health.new
      health.ensure(NeverAvailableDependency.new)
      health.ensure(AlwaysAvailableDependency.new)

      expect(health.summary).to match(/NeverAvailableDependency: FAIL/)
      expect(health.summary).to match(/AlwaysAvailableDependency: OK/)
    end

    it "includes the health of individual metrics" do
      health = LitmusPaper::Health.new
      health.perform(LitmusPaper::Metric::ConstantMetric.new(12))
      health.perform(LitmusPaper::Metric::ConstantMetric.new(34))

      expect(health.summary).to include("ConstantMetric(12): 12")
      expect(health.summary).to include("ConstantMetric(34): 34")
    end

    it "only runs each metric once" do
      health = LitmusPaper::Health.new
      metric = LitmusPaper::Metric::ConstantMetric.new(12)
      expect(metric).to receive(:current_health).once.and_return(12)

      health.perform(metric)
    end

    it "only runs each dependency once" do
      health = LitmusPaper::Health.new
      dependency = AlwaysAvailableDependency.new
      expect(dependency).to receive(:available?).once.and_return(true)

      health.ensure(dependency)
    end
  end
end
