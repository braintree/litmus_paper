ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'litmus_paper'
require 'tempfile'

TEST_CONFIG_DIR = "/tmp/litmus_paper"
TEST_CONFIG = File.expand_path('support/test.config', File.dirname(__FILE__))
TEST_D_CONFIG = File.expand_path('support/test.d.config', File.dirname(__FILE__))
TEST_CA_CERT = File.expand_path('ssl/server.crt', File.dirname(__FILE__))

Dir.glob("#{File.expand_path('support', File.dirname(__FILE__))}/**/*.rb").each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec
  config.include Rack::Test::Methods

  config.before :each do
    FileUtils.rm_rf TEST_CONFIG_DIR
    LitmusPaper.stub(:data_directory).and_return(TEST_CONFIG_DIR)
  end
end

module SpecHelper
  def self.create_temp_file(contents)
    file = Tempfile.new 'litmus_paper'
    file.write contents
    file.close
    file.path
  end

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
