require 'sinatra/base'

class HttpTestServer < Sinatra::Base
  get "/method" do
    text 200, "GET"
  end

  post "/method" do
    text 200, "POST"
  end

  get "/status/:response_status" do
    if params[:response_status] =~ /\A\d+\z/
      status = params[:response_status]
      message = Rack::Utils::HTTP_STATUS_CODES[status.to_i] || "Unknown"
      text status.to_i, "#{status} #{message}"
    else
      text 500, "Invalid Status"
    end
  end

  get "/sleep/:seconds" do
    sleep params[:seconds].to_f
    $stderr.puts "sleeping #{params[:seconds]}"
    text 200, "Woke up after #{params.inspect} seconds"
  end

  def text(response_code, body, headers ={})
    [response_code, { "Content-Type" => "text/plain" }.merge(headers), body]
  end
end
