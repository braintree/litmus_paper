require 'spec_helper'

describe IPVSLitmus::Service do

  describe "health" do
    it "is the sum of all the metrics' weight" do
      service = IPVSLitmus::Service.new('test', [], [ConstantMetric.new(50), ConstantMetric.new(25)])
      service.current_health.value.should == 75
    end

    it "is 0 when a dependency fails" do
      service = IPVSLitmus::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(50)])
      service.current_health.value.should == 0
    end

    it "is 0 when a down file exists" do
      service = IPVSLitmus::Service.new('test', [AlwaysAvailableDependency.new], [ConstantMetric.new(50)])

      write_down_file 'test', 'Down for testing'

      service.current_health.value.should == 0
      service.current_health.summary.should == "Down for testing"
    end

    it "is 0 when a global down file exists" do
      service = IPVSLitmus::Service.new('test', [AlwaysAvailableDependency.new], [ConstantMetric.new(50)])

      write_global_down_file 'Down for testing'

      service.current_health.value.should == 0
      service.current_health.summary.should == "Down for testing"
    end

    it "is 100 when an up file exists" do
      service = IPVSLitmus::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(50)])

      write_up_file 'test', 'Up for testing'

      service.current_health.value.should == 100
      service.current_health.summary.should == "Up for testing"
    end

    it "is 100 when a global up file exists" do
      service = IPVSLitmus::Service.new('test', [NeverAvailableDependency.new], [ConstantMetric.new(50)])

      write_global_up_file 'Up for testing'

      service.current_health.value.should == 100
      service.current_health.summary.should == "Up for testing"
    end
  end
end
