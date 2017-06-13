require 'spec_helper'

describe LitmusPaper::Metric::CPULoad do
  describe "#current_health" do
    it "is the percent of available cpu capacity" do
      LitmusPaper::Metric::CPULoad.any_instance.stub(
        :processor_count => 4,
        :load_average => 1.00,
      )
      cpu_load = LitmusPaper::Metric::CPULoad.new(40)
      cpu_load.current_health.should == 30
    end

    it "is one when the load is above one per core" do
      LitmusPaper::Metric::CPULoad.any_instance.stub(
        :processor_count => 4,
        :load_average => 20.00,
      )
      cpu_load = LitmusPaper::Metric::CPULoad.new(50)
      cpu_load.current_health.should == 1
    end
  end

  describe "#processor_count" do
    it "is a positive integer" do
      cpu_load = LitmusPaper::Metric::CPULoad.new(50)
      cpu_load.processor_count.should > 0
    end

    it "is cached" do
      File.should_receive(:readlines).with('/proc/cpuinfo').once.and_return(["processor       : 0\n"])
      cpu_load = LitmusPaper::Metric::CPULoad.new(50)
      cpu_load.processor_count
      cpu_load.processor_count
      cpu_load.processor_count
    end
  end

  describe "#load_average" do
    it "is a floating point" do
      cpu_load = LitmusPaper::Metric::CPULoad.new(50)
      cpu_load.load_average.should > 0.0
    end

    it "is not cached" do
      File.should_receive(:read).with('/proc/loadavg').twice.and_return("0.08 0.12 0.15 2/1190 9152\n")
      cpu_load = LitmusPaper::Metric::CPULoad.new(50)
      cpu_load.load_average.should > 0.0
      cpu_load.load_average.should > 0.0
    end
  end

  describe "#to_s" do
    it "is the check name and the maximum weight" do
      cpu_load = LitmusPaper::Metric::CPULoad.new(50)
      cpu_load.to_s.should == "Metric::CPULoad(50)"
    end
  end
end
