require 'spec_helper'

describe LitmusPaper::DeferredFacter do
  run_in_reactor

  describe "value" do
    it "executes Facter access on another thread" do
      processors = LitmusPaper::DeferredFacter.value("processorcount")
      processors.should match(/\d+/)
    end
  end
end
