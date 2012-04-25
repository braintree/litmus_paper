module IPVSLitmus
  class App < Sinatra::Base
    get "/status" do
      [200, { "Content-Type" => "text/plain" }, "OK"]
    end

    get "/:service/status" do
      service = IPVSLitmus.services[params[:service]]
      if service.nil?
        [404, { "Content-Type" => "text/plain" }, "NOT FOUND"]
      else
        health = service.current_health
        response_code = health.ok? ? 200 : 503
        body = "Health: #{health.value}\n"
        body << health.summary
        [response_code, { "Content-Type" => "text/plain" }, body]
      end
    end
  end
end
