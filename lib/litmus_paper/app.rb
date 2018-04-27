require 'sinatra/base'
require 'litmus_paper/terminal_output'
require 'json'

module LitmusPaper
  class App < Sinatra::Base
    disable :show_exceptions

    get "/" do
      _text 200, LitmusPaper::TerminalOutput.service_status
    end

    get "/status.json" do
      _json 200, LitmusPaper::TerminalOutput.service_status_json
    end

    delete "/down" do
      _delete_status_file(StatusFile.global_down_file)
    end

    post "/down" do
      _create_status_file(StatusFile.global_down_file)
    end

    delete "/up" do
      _delete_status_file(StatusFile.global_up_file)
    end

    post "/up" do
      _create_status_file(StatusFile.global_up_file)
    end

    delete "/health" do
      _delete_status_file(StatusFile.global_health_file)
    end

    post "/health" do
      _create_status_file(StatusFile.global_health_file)
    end

    get "/:service/status.json" do
      health = _cache.get(params[:service])
      _cache.set(
        params[:service],
        health = LitmusPaper.check_service(params[:service])
      ) unless health

      if health.nil?
        _json 404, { "status" => "NOT FOUND" }, { "X-Health" => "0" }
      else
        json = {
          :version => LitmusPaper::VERSION,
          :name => params[:service],
          :health => {},
          :checks => {},
          :dependencies => {}
        }
        if health.ok?
          response_code = 200
          status = "up"
        else
          response_code = 503
          status = "down"
        end
        json[:status] = status
        json[:response_code] = response_code

        headers = {"X-Health" => health.value.to_s}
        json[:health][:reported_health] = health.value
        json[:health][:measured_health] = health.measured_health
        if health.forced?
          if health.direction == :health
            status = "health"
            reason = health.forced_reason.split("\n").join(" ")
          else
            reason = health.forced_reason
          end
          json[:health][:forced] = reason
        end
        if health.forced?
          headers["X-Health-Forced"] = status
        end
        LitmusPaper.services[params[:service]].dependencies.each do |d|
          json[:dependencies][d] = health.ensure(d)
        end

        LitmusPaper.services[params[:service]].checks.each do |c|
          json[:checks][c] = health.perform(c)
        end
        _json response_code, json, headers
      end
    end

    get "/:service/status" do
      health = _cache.get(params[:service])
      _cache.set(
        params[:service],
        health = LitmusPaper.check_service(params[:service])
      ) unless health

      if health.nil?
        _text 404, "NOT FOUND", { "X-Health" => "0" }
      else
        if health.ok?
          response_code = 200
          status = "up"
        else
          response_code = 503
          status = "down"
        end

        headers = {"X-Health" => health.value.to_s}
        body = "Health: #{health.value}\n"
        body << "Measured Health: #{health.measured_health}\n"
        if health.forced?
          if health.direction == :health
            status = "health"
            reason = health.forced_reason.split("\n").join(" ")
          else
            reason = health.forced_reason
          end
          body << "Forced Reason: #{reason}\n"
        end
        body << health.summary

        if health.forced?
          headers["X-Health-Forced"] = status
        end

        _text response_code, body, headers
      end
    end

    delete "/:service/down" do
      _delete_status_file(StatusFile.service_down_file(params[:service]))
    end

    post "/:service/down" do
      _create_status_file(StatusFile.service_down_file(params[:service]))
    end

    delete "/:service/health" do
      _delete_status_file(StatusFile.service_health_file(params[:service]))
    end

    post "/:service/health" do
      _create_status_file(StatusFile.service_health_file(params[:service]))
    end

    delete "/:service/up" do
      _delete_status_file(StatusFile.service_up_file(params[:service]))
    end

    post "/:service/up" do
      _create_status_file(StatusFile.service_up_file(params[:service]))
    end

    get "/test/error" do
      raise "an error"
    end

    error do
      _text 500, "Server Error"
    end

    def _cache
      @cache ||= LitmusPaper::Cache.new(
        LitmusPaper.cache_location,
        "litmus_cache",
        LitmusPaper.cache_ttl
      )
    end

    def _create_status_file(status_file)
      status_file.create(params[:reason], params[:health])
      _text 201, "File created"
    end

    def _delete_status_file(status_file)
      if status_file.exists?
        status_file.delete
        _text 200, "File deleted"
      else
        _text 404, "NOT FOUND"
      end
    end

    def _json(response_code, body, headers={})
      [response_code, { "Content-Type" => "application/json" }.merge(headers), body.to_json]
    end

    def _text(response_code, body, headers ={})
      [response_code, { "Content-Type" => "text/plain" }.merge(headers), body]
    end
  end
end
