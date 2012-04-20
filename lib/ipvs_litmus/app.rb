module IPVSLitmus
  class App < Sinatra::Base
    get "/status" do
      "OK"
    end

    get "/:service/status" do
      service = IPVSLitmus.services[params[:service]]
      if service.nil?
        [404, "NOT FOUND"]
      elsif service.success?
        [200, "OK"]
      else
        [503, "FAIL"]
      end
    end
  end
end
