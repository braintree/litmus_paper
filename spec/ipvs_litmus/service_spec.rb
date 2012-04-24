require 'spec_helper'

describe IPVSLitmus::Service do
  describe "health" do
    it "is the sum of all the checks' weight" do
      service = IPVSLitmus::Service.new([], [ConstantAnalogCheck.new(50), ConstantAnalogCheck.new(25)])
      service.health.should == 75
    end

    it "is 0 when a dependency fails" do
      service = IPVSLitmus::Service.new([NeverAvailableDependency.new], [ConstantAnalogCheck.new(50)])
      service.health.should == 0
    end
  end
end
