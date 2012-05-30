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

module SpecHelper
  def self.wait_for_service(options)
    Timeout::timeout(options[:timeout] || 20) do
      loop do
        begin
          socket = TCPSocket.new(options[:host], options[:port])
          socket.close
          return
        rescue Exception
          sleep 0.5
        end
      end
    end
  end
end

IPVSLitmus.config_dir = "/tmp/ipvs"

TEST_CONFIG = File.expand_path('support/test.config', File.dirname(__FILE__))
