require 'spec_helper'

describe IPVSLitmus::Service do
  describe "health" do
    it "is the sum of all the metrics' weight" do
      service = IPVSLitmus::Service.new([], [ConstantMetric.new(50), ConstantMetric.new(25)])
      service.current_health.value.should == 75
    end

    it "is 0 when a dependency fails" do
      service = IPVSLitmus::Service.new([NeverAvailableDependency.new], [ConstantMetric.new(50)])
      service.current_health.value.should == 0
    end
  end
end
