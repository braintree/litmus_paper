require 'spec_helper'

describe IPVSLitmus::Metric::AvailableMemory do
  describe "#current_health" do
    it "multiplies weight by memory available" do
      facter = StubFacter.new({"memorytotal" => "10 GB", "memoryfree" => "5 GB"})
      memory = IPVSLitmus::Metric::AvailableMemory.new(50, facter)
      memory.current_health.should == 25
    end

    describe "#memory_total" do
      it "is a positive integer" do
        metric = IPVSLitmus::Metric::AvailableMemory.new(50)
        metric.memory_total.should > 1_000
      end

      it "is cached" do
        Facter.should_receive(:value).once.and_return("10 MB")
        metric = IPVSLitmus::Metric::AvailableMemory.new(50)
        metric.memory_total
        metric.memory_total
        metric.memory_total
      end
    end

    describe "#memory_free" do
      it "is a positive integer" do
        metric = IPVSLitmus::Metric::AvailableMemory.new(50)
        metric.memory_free.should > 100
      end
    end

    describe "#to_s" do
      it "is the name of the check and the max weight" do
        metric = IPVSLitmus::Metric::AvailableMemory.new(50)
        metric.to_s.should == "Metric::AvailableMemory(50)"
      end
    end
  end
end
