require 'pathname'
require 'net/http'
require 'net/https'
require 'uri'
require 'forwardable'

require 'async-rack'
require 'sinatra/base'
require 'em-synchrony/em-http'
require 'em/syslog'
require 'thin'
require 'facter'
require 'syslog_logger'

require 'facts/loadaverage'

require 'sinatra/synchrony'

require 'litmus_paper/app'
require 'litmus_paper/configuration'
require 'litmus_paper/deferred_facter'
require 'litmus_paper/dependency/http'
require 'litmus_paper/dependency/tcp'
require 'litmus_paper/health'
require 'litmus_paper/forced_health'
require 'litmus_paper/logger'
require 'litmus_paper/metric/available_memory'
require 'litmus_paper/metric/cpu_load'
require 'litmus_paper/service'
require 'litmus_paper/status_file'

require 'thin/callbacks'
require 'thin/backends/tcp_server_with_callbacks'
require 'thin/callback_rack_handler'

module LitmusPaper
  class << self
    attr_reader :services, :config_dir
    attr_accessor :logger
  end

  self.logger = Logger.new

  def self.configure(filename)
    @config_file = filename

    begin
      @services = LitmusPaper::Configuration.new(filename).evaluate
    rescue Exception
    end
  end

  def self.config_dir=(path)
    @config_dir = Pathname.new(path)
  end

  def self.reload
    configure(@config_file)
  end

  def self.reset
    @services = {}
  end
end

Signal.trap("HUP") { LitmusPaper.reload }
