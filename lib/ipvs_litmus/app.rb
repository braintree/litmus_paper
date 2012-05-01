module IPVSLitmus
  class App < Sinatra::Base
    post "/up" do
      FileUtils.mkdir_p IPVSLitmus.config_dir
      File.open(IPVSLitmus.config_dir.join('global_up'), 'w') do |file|
        file.puts params[:reason]
      end

      [201, "Global up file created"]
    end

    delete "/up" do
      global_upfile = IPVSLitmus.config_dir.join('global_up')
      if File.exists?(global_upfile)
        FileUtils.rm(global_upfile)
        [200, "Global up file deleted"]
      else
        [404, { "Content-Type" => "text/plain" }, "NOT FOUND"]
      end
    end

    post "/down" do
      FileUtils.mkdir_p IPVSLitmus.config_dir
      File.open(IPVSLitmus.config_dir.join('global_down'), 'w') do |file|
        file.puts params[:reason]
      end

      [201, "Global down file created"]
    end

    delete "/down" do
      global_downfile = IPVSLitmus.config_dir.join('global_down')
      if File.exists?(global_downfile)
        FileUtils.rm(global_downfile)
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
