require 'spec_helper'
require 'litmus_paper/agent_check_handler'

describe LitmusPaper::AgentCheckHandler do
  def app
    LitmusPaper::App
  end

  before :each do
    LitmusPaper.configure(TEST_CONFIG)
  end

  describe "output_service_status" do
    it "returns the forced health value for a healthy service" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      LitmusPaper::StatusFile.service_health_file("test").create("Forcing health", 88)
      LitmusPaper::AgentCheckHandler.handle("test").should == "ready\tup\t88%"
    end

    it "returns the actual health value for an unhealthy service when the measured health is less than the forced value" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      LitmusPaper::StatusFile.service_health_file("test").create("Forcing health", 88)
      LitmusPaper::AgentCheckHandler.handle("test").should == "ready\tup\t0%"
    end

    it "is 'ready' when the service is passing" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      LitmusPaper::AgentCheckHandler.handle("test").should == "ready\tup\t100%"
    end

    it "is 'down' when the check fails" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      LitmusPaper::AgentCheckHandler.handle("test").should == "down\t0%"
    end

    it "is 'failed' when the service is unknown" do
      LitmusPaper::AgentCheckHandler.handle("unknown").should == "failed#NOT_FOUND"
    end

    it "is 'drain' when an up file and down file exists" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      LitmusPaper::StatusFile.service_up_file("test").create("Up for testing")
      LitmusPaper::StatusFile.service_down_file("test").create("Down for testing")
      LitmusPaper::AgentCheckHandler.handle("test").should == "drain\t0%"
    end

    it "is 'drain' when a global down file and up file exists" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      LitmusPaper::StatusFile.global_down_file.create("Down for testing")
      LitmusPaper::StatusFile.global_up_file.create("Up for testing")
      LitmusPaper::AgentCheckHandler.handle("test").should == "drain\t0%"
    end

    it "is 'ready' when an up file exists" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      LitmusPaper::StatusFile.service_up_file("test").create("Up for testing")
      LitmusPaper::AgentCheckHandler.handle("test").should == "ready\tup\t100%"
    end

    it "is 'drain' when a global down file exists" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      LitmusPaper::StatusFile.global_down_file.create("Down for testing")
      LitmusPaper::AgentCheckHandler.handle("test").should == "drain\t0%"
    end

    it "is 'ready' when a global up file exists" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      LitmusPaper::StatusFile.global_up_file.create("Up for testing")
      LitmusPaper::AgentCheckHandler.handle("test").should == "ready\tup\t100%"
    end

    it "retrieves a cached value during the cache_ttl" do
      begin
        cache = LitmusPaper::AgentCheckHandler.instance_variable_get(:@cache)
        cache.instance_variable_set(:@ttl, 0.25)
        LitmusPaper::AgentCheckHandler.instance_variable_set(:@cache, cache)

        test_service = LitmusPaper::Service.new(
          'test',
          [AlwaysAvailableDependency.new],
          [LitmusPaper::Metric::ConstantMetric.new(100)]
        )
        LitmusPaper.services['test'] = test_service

        post "/test/health", :reason => "health for testing", :health => 88
        last_response.status.should == 201

        LitmusPaper::AgentCheckHandler.handle('test').should == "ready\tup\t88%"

        delete "/test/health"
        last_response.status.should == 200

        LitmusPaper::AgentCheckHandler.handle('test').should == "ready\tup\t88%"

        sleep 0.25

        LitmusPaper::AgentCheckHandler.handle('test').should_not == "ready\tup\t88%"
      ensure
        FileUtils.rm_rf(LitmusPaper.cache_location)
        cache = LitmusPaper::AgentCheckHandler.instance_variable_get(:@cache)
        cache.instance_variable_set(:@ttl, -1)
        LitmusPaper::AgentCheckHandler.instance_variable_set(:@cache, cache)
      end
    end
  end
end
