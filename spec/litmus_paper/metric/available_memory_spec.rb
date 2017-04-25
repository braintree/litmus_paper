require 'spec_helper'

describe LitmusPaper::Metric::AvailableMemory do
  describe "#current_health" do
    it "multiplies weight by memory available" do
      facter = StubFacter.new({"memorysize" => "10 GB", "memoryfree" => "5 GB"})
      memory = LitmusPaper::Metric::AvailableMemory.new(50, facter)
      expect(memory.current_health).to eq(25)
    end

    it "multiplies weight by memory available when handling floating point values" do
      facter = StubFacter.new({"memorysize" => "2.0 GB", "memoryfree" => "1.8 GB"})
      memory = LitmusPaper::Metric::AvailableMemory.new(50, facter)
      expect(memory.current_health).to eq(44)
    end

    describe "#memory_total" do
      it "is a positive integer" do
        metric = LitmusPaper::Metric::AvailableMemory.new(50)
        expect(metric.memory_total).to be > 1_000
      end

      it "handles floating point values properly" do
        facter = StubFacter.new("memorysize" => "1.80 GB")
        memory = LitmusPaper::Metric::AvailableMemory.new(50, facter)
        expect(memory.memory_total).to eq(1932735283)
      end

      it "is cached" do
        expect(Facter).to receive(:value).once.and_return("10 MB")
        metric = LitmusPaper::Metric::AvailableMemory.new(50)
        metric.memory_total
        metric.memory_total
        metric.memory_total
      end
    end

    describe "#memory_free" do
      it "is a positive integer" do
        metric = LitmusPaper::Metric::AvailableMemory.new(50)
        expect(metric.memory_free).to be > 100
      end

      it "handles floating point values properly" do
        facter = StubFacter.new("memoryfree" => "1.80 GB")
        memory = LitmusPaper::Metric::AvailableMemory.new(50, facter)
        expect(memory.memory_free).to eq(1932735283)
      end
    end

    describe "#to_s" do
      it "is the name of the check and the max weight" do
        metric = LitmusPaper::Metric::AvailableMemory.new(50)
        expect(metric.to_s).to eq("Metric::AvailableMemory(50)")
      end
    end
  end
end
