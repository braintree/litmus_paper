require 'spec_helper'
require 'litmus_paper/cli/agent_check'

describe LitmusPaper::CLI::AgentCheck do
  before :each do
    LitmusPaper.configure(TEST_CONFIG)
  end

  def agent_check(service)
    output = StringIO.new
    LitmusPaper::CLI::AgentCheck.new.output_service_status(service, output)
    output.rewind
    output.readline
  end

  describe "output_service_status" do
    it "returns the forced health value for a healthy service" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      LitmusPaper::StatusFile.service_health_file("test").create("Forcing health", 88)
      agent_check("test").should == "ready\t88%\r\n"
    end

    it "returns the actual health value for an unhealthy service when the measured health is less than the forced value" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      LitmusPaper::StatusFile.service_health_file("test").create("Forcing health", 88)
      agent_check("test").should == "ready\t0%\r\n"
    end

    it "is 'ready' when the service is passing" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      agent_check("test").should == "ready\t100%\r\n"
    end

    it "is 'down' when the check fails" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      agent_check("test").should == "down\t0%\r\n"
    end

    it "is 'failed' when the service is unknown" do
      agent_check("unknown").should == "failed#NOT_FOUND\r\n"
    end

    it "is 'drain' when an up file and down file exists" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      LitmusPaper::StatusFile.service_up_file("test").create("Up for testing")
      LitmusPaper::StatusFile.service_down_file("test").create("Down for testing")
      agent_check("test").should == "drain\t0%\r\n"
    end

    it "is 'drain' when a global down file and up file exists" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      LitmusPaper::StatusFile.global_down_file.create("Down for testing")
      LitmusPaper::StatusFile.global_up_file.create("Up for testing")
      agent_check("test").should == "drain\t0%\r\n"
    end

    it "is 'ready' when an up file exists" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      LitmusPaper::StatusFile.service_up_file("test").create("Up for testing")
      agent_check("test").should == "ready\t100%\r\n"
    end

    it "is 'drain' when a global down file exists" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      LitmusPaper::StatusFile.global_down_file.create("Down for testing")
      agent_check("test").should == "drain\t0%\r\n"
    end

    it "is 'ready' when a global up file exists" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      LitmusPaper::StatusFile.global_up_file.create("Up for testing")
      agent_check("test").should == "ready\t100%\r\n"
    end
  end
end
