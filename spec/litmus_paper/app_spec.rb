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

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('test')
      expect(last_response.body).to include('another')
    end

    it "includes the litmus version" do
      get "/"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Litmus Paper #{LitmusPaper::VERSION}")
    end

    it "includes the health of the service" do
      LitmusPaper.services['test'] = LitmusPaper::Service.new('test')
      LitmusPaper.services['another'] = LitmusPaper::Service.new('another')

      get "/"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('test')
      expect(last_response.body).to include('0')
    end

    it "includes the status if forced" do
      LitmusPaper.services['test'] = LitmusPaper::Service.new('test')
      LitmusPaper.services['another'] = LitmusPaper::Service.new('another')

      LitmusPaper::StatusFile.service_up_file("test").create("Up for testing")
      LitmusPaper::StatusFile.service_down_file("another").create("Down for testing")

      get "/"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Down for testing')
      expect(last_response.body).to include('Up for testing')
    end

    it "includes the health value if health is forced" do
      LitmusPaper.services['test'] = LitmusPaper::Service.new('test')
      LitmusPaper::StatusFile.service_health_file("test").create("Forcing health", 88)
      get "/"
      expect(last_response.body).to include('Forcing health')
      expect(last_response.body).to include('88')
    end
  end

  describe "POST /up" do
    it "creates a global upfile" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/up", :reason => "up for testing"
      expect(last_response.status).to eq(201)

      get "/test/status"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to match(/up for testing/)
    end
  end

  describe "POST /down" do
    it "creates a global downfile" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/down", :reason => "down for testing"
      expect(last_response.status).to eq(201)

      get "/test/status"
      expect(last_response.status).to eq(503)
      expect(last_response.body).to match(/down for testing/)
    end
  end

  describe "POST /health" do
    it "creates a global healthfile" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/health", :reason => "health for testing", :health => 88
      expect(last_response.status).to eq(201)

      get "/test/status"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to match(/health for testing 88/)
    end
  end

  describe "POST /:service/up" do
    it "creates a service specific upfile" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/test/up", :reason => "up for testing"
      expect(last_response.status).to eq(201)

      get "/test/status"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to match(/up for testing/)
    end
  end

  describe "POST /:service/health" do
    it "creates a service specific healthfile" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/test/health", :reason => "health for testing", :health => 88
      expect(last_response.status).to eq(201)

      get "/test/status"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to match(/health for testing 88/)
    end
  end

  describe "DELETE /up" do
    it "removes the global upfile" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/up", :reason => "up for testing"
      expect(last_response.status).to eq(201)

      get "/test/status"
      expect(last_response.status).to eq(200)

      delete "/up"
      expect(last_response.status).to eq(200)

      get "/test/status"
      expect(last_response.status).to eq(503)
      expect(last_response.body).not_to match(/up for testing/)
    end

    it "404s if there is no upfile" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])

      delete "/up"

      expect(last_response.status).to eq(404)
    end
  end

  describe "DELETE /down" do
    it "removes the global downfile" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/down", :reason => "down for testing"
      expect(last_response.status).to eq(201)

      get "/test/status"
      expect(last_response.status).to eq(503)

      delete "/down"
      expect(last_response.status).to eq(200)

      get "/test/status"
      expect(last_response).to be_ok
      expect(last_response.body).not_to match(/down for testing/)
    end
  end

  describe "DELETE /health" do
    it "removes the global healthfile" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/health", :reason => "health for testing", :health => 88
      expect(last_response.status).to eq(201)

      get "/test/status"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to match(/health for testing 88/)

      delete "/health"
      expect(last_response.status).to eq(200)

      get "/test/status"
      expect(last_response).to be_ok
      expect(last_response.body).not_to match(/health for testing 88/)
    end

    it "404s if there is no healthfile" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])

      delete "/health"

      expect(last_response.status).to eq(404)
    end
  end

  describe "DELETE /:service/up" do
    it "removes a service specific upfile" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/test/up", :reason => "up for testing"
      expect(last_response.status).to eq(201)

      get "/test/status"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to match(/up for testing/)

      delete "/test/up"
      expect(last_response.status).to eq(200)

      get "/test/status"
      expect(last_response.status).to eq(503)
    end
  end

  describe "DELETE /:service/health" do
    it "removes the service specific healthfile" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      post "/test/health", :reason => "health for testing", :health => 88
      expect(last_response.status).to eq(201)

      get "/test/status"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to match(/health for testing 88/)

      delete "/test/health"
      expect(last_response.status).to eq(200)

      get "/test/status"
      expect(last_response).to be_ok
      expect(last_response.body).not_to match(/health for testing 88/)
    end

    it "404s if there is no healthfile" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])

      delete "/test/health"

      expect(last_response.status).to eq(404)
    end
  end

  describe "GET /:service/status" do
    it "returns the forced health value for a healthy service" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      LitmusPaper::StatusFile.service_health_file("test").create("Forcing health", 88)

      get "/test/status"
      expect(last_response).to be_ok
      expect(last_response.header["X-Health"]).to eq("88")
      expect(last_response.body).to match(/Health: 88/)
      expect(last_response.body).to match(/Measured Health: 100/)
      expect(last_response.header["X-Health-Forced"]).to eq("health")
    end

    it "returns the actualy health value for an unhealthy service when the measured health is less than the forced value" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service
      LitmusPaper::StatusFile.service_health_file("test").create("Forcing health", 88)

      get "/test/status"
      expect(last_response).not_to be_ok
      expect(last_response.header["X-Health"]).to eq("0")
      expect(last_response.header["X-Health-Forced"]).to eq("health")
      expect(last_response.body).to match(/Health: 0/)
      expect(last_response.body).to match(/Measured Health: 0/)
      expect(last_response.body).to match(/Forcing health 88\n/)
    end

    it "is successful when the service is passing" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      get "/test/status"

      expect(last_response).to be_ok
      expect(last_response.header["Content-Type"]).to eq("text/plain")
      expect(last_response.header["X-Health"]).to eq("100")
      expect(last_response.header).not_to have_key("X-Health-Forced")
      expect(last_response.body).to match(/Health: 100/)
      expect(last_response.body).to match(/AlwaysAvailableDependency: OK/)
      expect(last_response.body).to include("Metric::ConstantMetric(100): 100")
    end

    it "is 'service unavailable' when the check fails" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      get "/test/status"

      expect(last_response.status).to eq(503)
      expect(last_response.header["Content-Type"]).to eq("text/plain")
      expect(last_response.header["X-Health"]).to eq("0")
      expect(last_response.body).to match(/Health: 0/)
    end

    it "is 'not found' when the service is unknown" do
      get "/unknown/status"

      expect(last_response.status).to eq(404)
      expect(last_response.header["Content-Type"]).to eq("text/plain")
    end

    it "is 'service unavailable' when an up file and down file exists" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      LitmusPaper::StatusFile.service_up_file("test").create("Up for testing")
      LitmusPaper::StatusFile.service_down_file("test").create("Down for testing")

      get "/test/status"

      expect(last_response.status).to eq(503)
      expect(last_response.headers["X-Health-Forced"]).to eq("down")
      expect(last_response.body).to match(/Down for testing/)
    end

    it "still reports the health, dependencies, and metrics when forced down" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      LitmusPaper::StatusFile.service_down_file("test").create("Down for testing")

      get "/test/status"

      expect(last_response.status).to eq(503)
      expect(last_response.headers["X-Health-Forced"]).to eq("down")
      expect(last_response.body).to match(/Measured Health: 100\n/)
      expect(last_response.body).to match(/AlwaysAvailableDependency: OK\n/)
      expect(last_response.body).to match(/Metric::ConstantMetric\(100\): 100\n/)
    end

    it "still reports the health, dependencies, and metrics when forced up" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      LitmusPaper::StatusFile.service_up_file("test").create("Up for testing")

      get "/test/status"

      expect(last_response.status).to eq(200)
      expect(last_response.headers["X-Health-Forced"]).to eq("up")
      expect(last_response.body).to match(/Measured Health: 100\n/)
      expect(last_response.body).to match(/AlwaysAvailableDependency: OK\n/)
      expect(last_response.body).to match(/Metric::ConstantMetric\(100\): 100\n/)
    end

    it "is 'service available' when an up file exists" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      LitmusPaper::StatusFile.service_up_file("test").create("Up for testing")

      get "/test/status"

      expect(last_response.status).to eq(200)
      expect(last_response.headers["X-Health-Forced"]).to eq("up")
      expect(last_response.body).to match(/Up for testing/)
    end

    it "is 'service unavailable' when a global down file and up file exists" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      LitmusPaper::StatusFile.global_down_file.create("Down for testing")
      LitmusPaper::StatusFile.global_up_file.create("Up for testing")

      get "/test/status"

      expect(last_response.status).to eq(503)
      expect(last_response.headers["X-Health-Forced"]).to eq("down")
      expect(last_response.body).to match(/Down for testing/)
    end

    it "is 'service unavailable' when a global down file exists" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      LitmusPaper::StatusFile.global_down_file.create("Down for testing")

      get "/test/status"

      expect(last_response.status).to eq(503)
      expect(last_response.headers["X-Health-Forced"]).to eq("down")
      expect(last_response.body).to match(/Down for testing/)
    end

    it "is successful when a global up file exists" do
      test_service = LitmusPaper::Service.new('test', [NeverAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      LitmusPaper::StatusFile.global_up_file.create("Up for testing")

      get "/test/status"

      expect(last_response.status).to eq(200)
      expect(last_response.headers["X-Health-Forced"]).to eq("up")
      expect(last_response.body).to match(/Up for testing/)
    end

    it "resets the Facter cache" do
      test_service = LitmusPaper::Service.new('test', [AlwaysAvailableDependency.new], [LitmusPaper::Metric::ConstantMetric.new(100)])
      LitmusPaper.services['test'] = test_service

      get "/test/status"
      expect(last_response).to be_ok

      facter_uptime = Facter.value("uptime_seconds")
      sleep 1

      get "/test/status"
      expect(last_response).to be_ok

      expect(Facter.value("uptime_seconds")).to be > facter_uptime
    end
  end

  describe "server errors" do
    it "responds with a text/plain 500 response" do
      old_environment = :test
      begin
        app.environment = :production
        get "/test/error"
        expect(last_response.status).to eq(500)
        expect(last_response.headers["Content-Type"]).to eq("text/plain")
        expect(last_response.body).to eq("Server Error")
      ensure
        app.environment = old_environment
      end
    end
  end
end
