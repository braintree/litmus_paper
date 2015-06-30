module LitmusPaper
  class App < Sinatra::Base
    disable :show_exceptions

    get "/" do
      _text 200, LitmusPaper::TerminalOutput.service_status
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

    get "/:service/status" do
      health = LitmusPaper.check_service(params[:service])
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
        if health.forced?
          body << "Measured Health: #{health.measured_health}\n"
          body << "Forced Reason: #{health.forced_reason}\n"
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

    def _create_status_file(status_file)
      status_file.create(params[:reason])
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

    def _text(response_code, body, headers ={})
      [response_code, { "Content-Type" => "text/plain" }.merge(headers), body]
    end
  end
end
