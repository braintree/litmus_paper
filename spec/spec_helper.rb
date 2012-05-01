ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'ipvs_litmus'

Dir.glob("#{File.expand_path('support', File.dirname(__FILE__))}/**/*.rb").each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec
  config.include Rack::Test::Methods

  config.before :each do
    FileUtils.rm_rf(IPVSLitmus.config_dir)
    IPVSLitmus.reset
  end
end

IPVSLitmus.config_dir = "/tmp/ipvs"

TEST_CONFIG = File.expand_path('support/test.config', File.dirname(__FILE__))
