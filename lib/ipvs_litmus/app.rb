module IPVSLitmus
  class App < Sinatra::Base
    get "/status" do
      "OK"
    end

    get "/:service/status" do
      service = IPVSLitmus.services[params[:service]]
      if service.nil?
        [404, "NOT FOUND"]
      else
        health = service.current_health
        response_code = health.ok? ? 200 : 503
        body = "Health: #{health.value}\n"
        body << health.summary
        [response_code, body]
      end
    end
  end
end
