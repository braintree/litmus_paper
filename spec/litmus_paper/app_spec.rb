require 'spec_helper'

describe LitmusPaper::App do
  def app
    LitmusPaper::App
  end

  before :each do
    LitmusPaper.configure(TEST_CONFIG)
  end

  describe "GET /" do
    it "returns the list of services litmus monitors" do
      LitmusPaper.services['test'] = LitmusPaper::Service.new('test')
      LitmusPaper.services['another'] = LitmusPaper::Service.new('another')

      get "/"

      last_response.status.should == 200
      last_response.body.should include('test')
      last_response.body.should include('another')
    end

    it "includes the litmus version" do
      get "/"

      last_response.status.should == 200
      last_response.body.should include("Litmus Paper #{LitmusPaper::VERSION}")
    end

    it "includes the health of the service" do
      LitmusPaper.services['test'] = LitmusPaper::Service.new('test')
      LitmusPaper.services['another'] = LitmusPaper::Service.new('another')

      get "/"

      last_response.status.should == 200
      last_response.body.should include('test')
      last_response.body.should include('0')
    end

    it "includes the status if forced" do
      LitmusPaper.services['test'] = LitmusPaper::Service.new('test')
      LitmusPaper.services['another'] = LitmusPaper::Service.new('another')

      LitmusPaper::StatusFile.service_up_file("test").create("Up for testing")
      LitmusPaper::StatusFile.service_down_file("another").create("Down for testing")

      get "/"

      last_response.status.should == 200
      last_response.body.should include('Down for testing')
      last_response.body.should include('Up for testing')
    end

    it "includes the health value if health is forced" do
      LitmusPaper.services['test'] = LitmusPaper::Service.new('test')
      LitmusPaper::StatusFile.service_health_file("test").create("Forcing health", 88)
      get "/"
      last_response.body.should include('Forcing health')
      last_response.body.should include('88')
    end

    it "returns successfully if a haproxy backend socket is unreachable" do
      LitmusPaper.services['test'] = LitmusPaper::Service.new('test', [], [LitmusPaper::Metric::HaproxyBackendsHealth.new(100, "/tmp/non-existant-socketfile", "haproxy")])

      get "/"

      last_response.status.should == 200
      last_response.body.should include('test')
      last_response.body.should include('0')
    end
  end

  describe "POST /up" do
    it "creates a global upfile" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/up", :reason => "up for testing"
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 200
      last_response.body.should match(/up for testing/)
    end
  end

  describe "POST /down" do
    it "creates a global downfile" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/down", :reason => "down for testing"
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 503
      last_response.body.should match(/down for testing/)
    end
  end

  describe "POST /health" do
    it "creates a global healthfile" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/health", :reason => "health for testing", :health => 88
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 200
      last_response.body.should match(/health for testing 88/)
    end
  end

  describe "POST /:service/up" do
    it "creates a service specific upfile" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/test/up", :reason => "up for testing"
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 200
      last_response.body.should match(/up for testing/)
    end
  end

  describe "POST /:service/health" do
    it "creates a service specific healthfile" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/test/health", :reason => "health for testing", :health => 88
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 200
      last_response.body.should match(/health for testing 88/)
    end
  end

  describe "DELETE /up" do
    it "removes the global upfile" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/up", :reason => "up for testing"
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 200

      delete "/up"
      last_response.status.should == 200

      get "/test/status"
      last_response.status.should == 503
      last_response.body.should_not match(/up for testing/)
    end

    it "404s if there is no upfile" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])

      delete "/up"

      last_response.status.should == 404
    end
  end

  describe "DELETE /down" do
    it "removes the global downfile" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/down", :reason => "down for testing"
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 503

      delete "/down"
      last_response.status.should == 200

      get "/test/status"
      last_response.should be_ok
      last_response.body.should_not match(/down for testing/)
    end
  end

  describe "DELETE /health" do
    it "removes the global healthfile" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/health", :reason => "health for testing", :health => 88
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 200
      last_response.body.should match(/health for testing 88/)

      delete "/health"
      last_response.status.should == 200

      get "/test/status"
      last_response.should be_ok
      last_response.body.should_not match(/health for testing 88/)
    end

    it "404s if there is no healthfile" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])

      delete "/health"

      last_response.status.should == 404
    end
  end

  describe "DELETE /:service/up" do
    it "removes a service specific upfile" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/test/up", :reason => "up for testing"
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 200
      last_response.body.should match(/up for testing/)

      delete "/test/up"
      last_response.status.should == 200

      get "/test/status"
      last_response.status.should == 503
    end
  end

  describe "DELETE /:service/health" do
    it "removes the service specific healthfile" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/test/health", :reason => "health for testing", :health => 88
      last_response.status.should == 201

      get "/test/status"
      last_response.status.should == 200
      last_response.body.should match(/health for testing 88/)

      delete "/test/health"
      last_response.status.should == 200

      get "/test/status"
      last_response.should be_ok
      last_response.body.should_not match(/health for testing 88/)
    end

    it "404s if there is no healthfile" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])

      delete "/test/health"

      last_response.status.should == 404
    end
  end

  describe "GET /:service/status" do
    it "returns the forced health value for a healthy service" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      LitmusPaper::StatusFile.service_health_file("test").create("Forcing health", 88)

      get "/test/status"
      last_response.should be_ok
      last_response.header["X-Health"].should == "88"
      last_response.body.should match(/Health: 88/)
      last_response.body.should match(/Measured Health: 100/)
      last_response.header["X-Health-Forced"].should == "health"
    end

    it "returns the actual health value for an unhealthy service when the measured health is less than the forced value" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      LitmusPaper::StatusFile.service_health_file("test").create("Forcing health", 88)

      get "/test/status"
      last_response.should_not be_ok
      last_response.header["X-Health"].should == "0"
      last_response.header["X-Health-Forced"].should == "health"
      last_response.body.should match(/Health: 0/)
      last_response.body.should match(/Measured Health: 0/)
      last_response.body.should match(/Forcing health 88\n/)
    end

    it "is successful when the service is passing" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      get "/test/status"

      last_response.should be_ok
      last_response.header["Content-Type"].should == "text/plain"
      last_response.header["X-Health"].should == "100"
      last_response.header.should_not have_key("X-Health-Forced")
      last_response.body.should match(/Health: 100/)
      last_response.body.should match(/Measured Health: 100/)
      last_response.body.should match(/AlwaysAvailableDependency: OK/)
      last_response.body.should include("Metric::ConstantMetric(100): 100")
    end

    it "is 'service unavailable' when the check fails" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      get "/test/status"

      last_response.status.should == 503
      last_response.header["Content-Type"].should == "text/plain"
      last_response.header["X-Health"].should == "0"
      last_response.body.should match(/Health: 0/)
      last_response.body.should match(/Measured Health: 0/)
    end

    it "is 'not found' when the service is unknown" do
      get "/unknown/status"

      last_response.status.should == 404
      last_response.header["Content-Type"].should == "text/plain"
    end

    it "is 'service unavailable' when an up file and down file exists" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      LitmusPaper::StatusFile.service_up_file("test").create("Up for testing")
      LitmusPaper::StatusFile.service_down_file("test").create("Down for testing")

      get "/test/status"

      last_response.status.should == 503
      last_response.headers["X-Health-Forced"].should == "down"
      last_response.body.should match(/Down for testing/)
    end

    it "still reports the health, dependencies, and metrics when forced down" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      LitmusPaper::StatusFile.service_down_file("test").create("Down for testing")

      get "/test/status"

      last_response.status.should == 503
      last_response.headers["X-Health-Forced"].should == "down"
      last_response.body.should match(/Measured Health: 100\n/)
      last_response.body.should match(/AlwaysAvailableDependency: OK\n/)
      last_response.body.should match(/Metric::ConstantMetric\(100\): 100\n/)
    end

    it "still reports the health, dependencies, and metrics when forced up" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      LitmusPaper::StatusFile.service_up_file("test").create("Up for testing")

      get "/test/status"

      last_response.status.should == 200
      last_response.headers["X-Health-Forced"].should == "up"
      last_response.body.should match(/Measured Health: 100\n/)
      last_response.body.should match(/AlwaysAvailableDependency: OK\n/)
      last_response.body.should match(/Metric::ConstantMetric\(100\): 100\n/)
    end

    it "is 'service available' when an up file exists" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      LitmusPaper::StatusFile.service_up_file("test").create("Up for testing")

      get "/test/status"

      last_response.status.should == 200
      last_response.headers["X-Health-Forced"].should == "up"
      last_response.body.should match(/Up for testing/)
    end

    it "is 'service unavailable' when a global down file and up file exists" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      LitmusPaper::StatusFile.global_down_file.create("Down for testing")
      LitmusPaper::StatusFile.global_up_file.create("Up for testing")

      get "/test/status"

      last_response.status.should == 503
      last_response.headers["X-Health-Forced"].should == "down"
      last_response.body.should match(/Down for testing/)
    end

    it "is 'service unavailable' when a global down file exists" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      LitmusPaper::StatusFile.global_down_file.create("Down for testing")

      get "/test/status"

      last_response.status.should == 503
      last_response.headers["X-Health-Forced"].should == "down"
      last_response.body.should match(/Down for testing/)
    end

    it "is successful when a global up file exists" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      LitmusPaper::StatusFile.global_up_file.create("Up for testing")

      get "/test/status"

      last_response.status.should == 200
      last_response.headers["X-Health-Forced"].should == "up"
      last_response.body.should match(/Up for testing/)
    end

    it "retrieves a cached value during the cache_ttl" do
      begin
        cache = LitmusPaper::Cache.new(
          location = "/tmp/litmus_cache",
          namespace = "test_cache",
          ttl = 0.05
        )
        LitmusPaper::App.any_instance.stub(:_cache).and_return(cache)
        test_service = LitmusPaper::Service.new(
          'test',
          [AlwaysAvailableDependency.new],
          [LitmusPaper::Metric::ConstantMetric.new(100)]
        )
        LitmusPaper.services['test'] = test_service

        post "/test/health", :reason => "health for testing", :health => 88
        last_response.status.should == 201

        get "/test/status"
        last_response.status.should == 200
        last_response.body.should match(/health for testing 88/)

        delete "/test/health"
        last_response.status.should == 200

        get "/test/status"
        last_response.should be_ok
        last_response.body.should match(/health for testing 88/)

        sleep ttl

        get "/test/status"
        last_response.should be_ok
        last_response.body.should_not match(/health for testing 88/)
      ensure
        FileUtils.rm_rf(location)
      end
    end
  end

  describe "GET /:service/metrics" do
    it "returns the forced health value for a healthy service" do
      LitmusPaper::Metric::UnixSocketUtilization.any_instance.stub(
        :_stats => OpenStruct.new({:queued => 7, :active => 10}),
      )
      LitmusPaper::Metric::CPULoad.any_instance.stub(
        :load_average => 0.1
      )
      cpu_load = LitmusPaper::Metric::CPULoad.new(50)
      socket_utilization = LitmusPaper::Metric::UnixSocketUtilization.new(100, '/var/run/foo.sock', 10)
      internet_health = LitmusPaper::Metric::InternetHealth.new(100, [
        "127.0.0.1:3000",
        "127.0.0.1:3001",
      ])
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [
        cpu_load,
        socket_utilization,
        internet_health,
      ])
      LitmusPaper.services['test'] = test_service

      get "/test/metrics"
      last_response.should be_ok
      last_response.body.should match %r(cpu_load_average{service="test"} 0.1)
      last_response.body.should match %r(active{service="test"} 10)
      last_response.body.should match %r(queued{service="test"} 7)
      last_response.body.should match %r(utilization{service="test"} 70)
    end
  end

  describe "server errors" do
    it "responds with a text/plain 500 response" do
      old_environment = :test
      begin
        app.environment = :production
        get "/test/error"
        last_response.status.should == 500
        last_response.headers["Content-Type"].should == "text/plain"
        last_response.body.should == "Server Error"
      ensure
        app.environment = old_environment
      end
    end
  end
end
