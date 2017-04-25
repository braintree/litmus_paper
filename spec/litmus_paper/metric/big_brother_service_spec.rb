require 'spec_helper'

describe LitmusPaper::Metric::BigBrotherService do
  describe "#current_health" do
    it "returns the aggregate health of a Big Brother service." do
      expect(Net::HTTP).to receive(:get).
        with('127.0.0.1', '/cluster/service', 9292).
        and_return('Running: true\nCombinedWeight: 300\n')

      big_brother = LitmusPaper::Metric::BigBrotherService.new('service')
      expect(big_brother.current_health).to eq(300)
    end
  end

  describe "#to_s" do
    it "is the check name and the service name" do
      cpu_load = LitmusPaper::Metric::BigBrotherService.new('service')
      expect(cpu_load.to_s).to eq("Metric::BigBrotherService(service)")
    end
  end
end
