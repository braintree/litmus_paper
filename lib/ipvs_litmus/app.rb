module IPVSLitmus
  class App < Sinatra::Base
    post "/up" do
      global_upfile = StatusFile.new('global_up')
      global_upfile.create(params[:reason])

      [201, "Global up file created"]
    end

    delete "/up" do
      global_upfile = StatusFile.new('global_up')
      if global_upfile.exists?
        global_upfile.delete
        [200, "Global up file deleted"]
      else
        [404, { "Content-Type" => "text/plain" }, "NOT FOUND"]
      end
    end

    post "/down" do
      global_downfile = StatusFile.new('global_down')
      global_downfile.create(params[:reason])

      [201, "Global down file created"]
    end

    delete "/down" do
      global_downfile = StatusFile.new('global_down')
      if global_downfile.exists?
        global_downfile.delete
        [200, "Global down file deleted"]
      else
        [404, { "Content-Type" => "text/plain" }, "NOT FOUND"]
      end
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
