require 'spec_helper'

describe IPVSLitmus::Health do
  describe "#calculate" do
    it "given complete chaos it is 1" do
      hardware = StubHardware.new(:memory_free => 0, :load => 1000)
      health = IPVSLitmus::Health.new(hardware)
      health.calculate.should == 1
    end
  end
end
