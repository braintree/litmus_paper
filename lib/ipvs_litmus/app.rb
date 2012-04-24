module IPVSLitmus
  class App < Sinatra::Base
    get "/status" do
      "OK"
    end

    get "/:service/status" do
      service = IPVSLitmus.services[params[:service]]
      if service.nil?
        [404, "NOT FOUND"]
      elsif service.health > 0
        [200, "Health: #{service.health}"]
      else
        [503, "FAIL"]
      end
    end
  end
end
