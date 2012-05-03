module IPVSLitmus
  class App < Sinatra::Base
    get "/" do
      output = "Services monitored:\n"
      output +=  IPVSLitmus.services.keys.join("\n")

      text 200, output
    end

    post "/force/*" do
      path = *status_file_path(params[:splat])
      statusfile = StatusFile.new(*path)
      statusfile.create(params[:reason])

      text 201, "File created"
    end

    delete "/force/*" do
      path = *status_file_path(params[:splat])
      statusfile = StatusFile.new(*path)
      if statusfile.exists?
        statusfile.delete
        text 200, "File deleted"
      else
        text 404, "NOT FOUND"
      end
    end

    get "/:service/status" do
      service = IPVSLitmus.services[params[:service]]
      if service.nil?
        text 404, "NOT FOUND", { "X-Health" => "0" }
      else
        health = service.current_health
        response_code = health.ok? ? 200 : 503
        body = "Health: #{health.value}\n"
        body << health.summary
        text response_code, body, { "X-Health" => health.value.to_s }
      end
    end

    def text(response_code, body, headers ={})
      [response_code, { "Content-Type" => "text/plain" }.merge(headers), body]
    end

    def status_file_path(splat)
      path = splat.first.split("/")
      if path.size == 1
        ["global_#{path.first}"]
      else
        path
      end
    end
  end
end
