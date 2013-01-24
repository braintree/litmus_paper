require 'sinatra/base'

class HttpTestServer < Sinatra::Base
  get "/method" do
    text 200, "GET"
  end

  post "/method" do
    text 200, "POST"
  end

  get "/fail_if_no_agent" do
    if request.user_agent.nil?
      text 400, "No user agent"
    else
      text 200, "OK"
    end
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

  get '/basic_auth' do
    requires_basic_auth!('admin', 'admin')
    "Welcome, authenticated client"
  end

  get '/basic_auth_without_password' do
    requires_basic_auth!('justadmin', '')
    "Welcome, authenticated client"
  end

  get '/basic_auth_without_user' do
    requires_basic_auth!('', 'justpassword')
    "Welcome, authenticated client"
  end

  get '/return_next_path_segment/:something' do
    params[:something]
  end

  def text(response_code, body, headers ={})
    [response_code, { "Content-Type" => "text/plain" }.merge(headers), body]
  end

  helpers do
    def requires_basic_auth!(user, pass)
      unless authorized?(user, pass)
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?(user, pass)
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [user, pass]
    end
  end
end
