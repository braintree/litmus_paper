ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'ipvs_litmus'

RSpec.configure do |config|
  config.expect_with :rspec
  config.include Rack::Test::Methods
end
