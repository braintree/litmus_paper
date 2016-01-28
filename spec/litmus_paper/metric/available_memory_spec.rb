require 'spec_helper'

describe LitmusPaper::Metric::AvailableMemory do
  describe "#current_health" do
    it "multiplies weight by memory available" do
      facter = StubFacter.new({"memorysize" => "10 GB", "memoryfree" => "5 GB"})
      memory = LitmusPaper::Metric::AvailableMemory.new(50, facter)
      memory.current_health.should == 25
    end

    it "multiplies weight by memory available when handling floating point values" do
      facter = StubFacter.new({"memorysize" => "2.0 GB", "memoryfree" => "1.8 GB"})
      memory = LitmusPaper::Metric::AvailableMemory.new(50, facter)
      memory.current_health.should == 44
    end

    describe "#memory_total" do
      it "is a positive integer" do
        metric = LitmusPaper::Metric::AvailableMemory.new(50)
        metric.memory_total.should > 1_000
      end

      it "handles floating point values properly" do
        facter = StubFacter.new("memorysize" => "1.80 GB")
        memory = LitmusPaper::Metric::AvailableMemory.new(50, facter)
        memory.memory_total.should == 1932735283
      end

      it "is cached" do
        Facter.should_receive(:value).once.and_return("10 MB")
        metric = LitmusPaper::Metric::AvailableMemory.new(50)
        metric.memory_total
        metric.memory_total
        metric.memory_total
      end
    end

    describe "#memory_free" do
      it "is a positive integer" do
        metric = LitmusPaper::Metric::AvailableMemory.new(50)
        metric.memory_free.should > 100
      end

      it "handles floating point values properly" do
        facter = StubFacter.new("memoryfree" => "1.80 GB")
        memory = LitmusPaper::Metric::AvailableMemory.new(50, facter)
        memory.memory_free.should == 1932735283
      end
    end

    describe "#to_s" do
      it "is the name of the check and the max weight" do
        metric = LitmusPaper::Metric::AvailableMemory.new(50)
        metric.to_s.should == "Metric::AvailableMemory(50)"
      end
    end
  end
end
