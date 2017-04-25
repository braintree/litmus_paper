require 'spec_helper'

describe LitmusPaper::Service do
  describe "health" do
    it "is the sum of all the metrics' weight" do
      service = LitmusPaper::Service.new('test')
      service.measure_health LitmusPaper::Metric::ConstantMetric, :weight => 50
      service.measure_health LitmusPaper::Metric::ConstantMetric, :weight => 25

      expect(service.current_health.value).to eq(75)
    end

    it "is 0 when a dependency fails" do
      service = LitmusPaper::Service.new('test')
      service.depends NeverAvailableDependency
      service.measure_health LitmusPaper::Metric::ConstantMetric, :weight => 50

      expect(service.current_health.value).to eq(0)
    end

    it "is 0 when a down file exists" do
      service = LitmusPaper::Service.new('test')
      service.depends AlwaysAvailableDependency
      service.measure_health LitmusPaper::Metric::ConstantMetric, :weight => 50

      LitmusPaper::StatusFile.service_down_file("test").create("Down for testing")

      expect(service.current_health.value).to eq(0)
      expect(service.current_health.forced_reason).to match(/Down for testing/)
    end

    it "is 0 when a global down file exists" do
      service = LitmusPaper::Service.new('test')
      service.depends AlwaysAvailableDependency
      service.measure_health LitmusPaper::Metric::ConstantMetric, :weight => 50

      LitmusPaper::StatusFile.global_down_file.create("Down for testing")

      expect(service.current_health.value).to eq(0)
      expect(service.current_health.forced_reason).to match(/Down for testing/)
    end

    it "is 100 when an up file exists" do
      service = LitmusPaper::Service.new('test')
      service.depends NeverAvailableDependency
      service.measure_health LitmusPaper::Metric::ConstantMetric, :weight => 50

      LitmusPaper::StatusFile.service_up_file("test").create("Up for testing")

      expect(service.current_health.value).to eq(100)
      expect(service.current_health.forced_reason).to match(/Up for testing/)
    end

    it "is 100 when a global up file exists" do
      service = LitmusPaper::Service.new('test')
      service.depends NeverAvailableDependency
      service.measure_health LitmusPaper::Metric::ConstantMetric, :weight => 50

      LitmusPaper::StatusFile.global_up_file.create("Up for testing")

      expect(service.current_health.value).to eq(100)
      expect(service.current_health.forced_reason).to match(/Up for testing/)
    end
  end
end
