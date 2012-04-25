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
    end

    describe "#memory_free" do
      it "is a positive integer" do
        metric = IPVSLitmus::Metric::AvailableMemory.new(50)
        metric.memory_free.should > 100
      end
    end
  end
end
