ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'ipvs_litmus'

Dir.glob("#{File.expand_path('support', File.dirname(__FILE__))}/**/*.rb").each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec
  config.include Rack::Test::Methods

end

IPVSLitmus.config_dir = "/tmp/ipvs"
