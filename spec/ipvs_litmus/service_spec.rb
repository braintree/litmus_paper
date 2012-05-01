require 'spec_helper'

describe IPVSLitmus::Service do
  describe "health" do
    it "is the sum of all the metrics' weight" do
      service = IPVSLitmus::Service.new('test')
      service.measure_health ConstantMetric, :weight => 50
      service.measure_health ConstantMetric, :weight => 25

      service.current_health.value.should == 75
    end

    it "is 0 when a dependency fails" do
      service = IPVSLitmus::Service.new('test')
      service.depends NeverAvailableDependency
      service.measure_health ConstantMetric, :weight => 50

      service.current_health.value.should == 0
    end

    it "is 0 when a down file exists" do
      service = IPVSLitmus::Service.new('test')
      service.depends AlwaysAvailableDependency
      service.measure_health ConstantMetric, :weight => 50

      IPVSLitmus::StatusFile.new("down", "test").create("Down for testing")

      service.current_health.value.should == 0
      service.current_health.summary.should == "Down for testing"
    end

    it "is 0 when a global down file exists" do
      service = IPVSLitmus::Service.new('test')
      service.depends AlwaysAvailableDependency
      service.measure_health ConstantMetric, :weight => 50

      IPVSLitmus::StatusFile.new("down", "test").create("Down for testing")

      service.current_health.value.should == 0
      service.current_health.summary.should == "Down for testing"
    end

    it "is 100 when an up file exists" do
      service = IPVSLitmus::Service.new('test')
      service.depends NeverAvailableDependency
      service.measure_health ConstantMetric, :weight => 50

      IPVSLitmus::StatusFile.new("up", "test").create("Up for testing")

      service.current_health.value.should == 100
      service.current_health.summary.should == "Up for testing"
    end

    it "is 100 when a global up file exists" do
      service = IPVSLitmus::Service.new('test')
      service.depends NeverAvailableDependency
      service.measure_health ConstantMetric, :weight => 50

      IPVSLitmus::StatusFile.new("global_up").create("Up for testing")

      service.current_health.value.should == 100
      service.current_health.summary.should == "Up for testing"
    end
  end
end
