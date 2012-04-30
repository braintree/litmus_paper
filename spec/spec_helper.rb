ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'ipvs_litmus'

Dir.glob("#{File.expand_path('support', File.dirname(__FILE__))}/**/*.rb").each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec
  config.include Rack::Test::Methods

  config.before(:each) do
    FileUtils.rm_rf(IPVSLitmus.config_dir)
  end
end

IPVSLitmus.config_dir = "/tmp/ipvs"

def write_down_file(service_name, message)
  FileUtils.mkdir_p IPVSLitmus.config_dir.join('down')
  File.open(IPVSLitmus.config_dir.join('down', service_name), 'w') do |file|
    file.puts message
  end
end

def write_up_file(service_name, message)
  FileUtils.mkdir_p IPVSLitmus.config_dir.join('up')
  File.open(IPVSLitmus.config_dir.join('up', service_name), 'w') do |file|
    file.puts message
  end
end
