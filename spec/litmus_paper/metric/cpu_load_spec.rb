require 'spec_helper'

describe LitmusPaper::Metric::CPULoad do
  describe "#current_health" do
    it "is the percent of available cpu capacity" do
      facter = StubFacter.new({"processorcount" => "4", "loadaverage" => "1.00 0.40 0.10"})
      cpu_load = LitmusPaper::Metric::CPULoad.new(40, facter)
      expect(cpu_load.current_health).to eq(30)
    end

    it "is one when the load is above one per core" do
      facter = StubFacter.new({"processorcount" => "4", "loadaverage" => "20.00 11.40 10.00"})
      cpu_load = LitmusPaper::Metric::CPULoad.new(50, facter)
      expect(cpu_load.current_health).to eq(1)
    end
  end

  describe "#processor_count" do
    it "is a positive integer" do
      cpu_load = LitmusPaper::Metric::CPULoad.new(50)
      expect(cpu_load.processor_count).to be > 0
    end

    it "is cached" do
      expect(Facter).to receive(:value).once.and_return("10")
      cpu_load = LitmusPaper::Metric::CPULoad.new(50)
      cpu_load.processor_count
      cpu_load.processor_count
      cpu_load.processor_count
    end
  end

  describe "#load_average" do
    it "is a floating point" do
      cpu_load = LitmusPaper::Metric::CPULoad.new(50)
      expect(cpu_load.load_average).to be > 0.0
    end
  end

  describe "#to_s" do
    it "is the check name and the maximum weight" do
      cpu_load = LitmusPaper::Metric::CPULoad.new(50)
      expect(cpu_load.to_s).to eq("Metric::CPULoad(50)")
    end
  end
end
