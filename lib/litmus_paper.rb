require 'pathname'
require 'net/http'
require 'net/https'
require 'uri'
require 'forwardable'

require 'sinatra/base'
require 'facter'
require 'syslog_logger'

require 'facts/loadaverage'

require 'litmus_paper/app'
require 'litmus_paper/configuration'
require 'litmus_paper/dependency/haproxy_backends'
require 'litmus_paper/dependency/http'
require 'litmus_paper/dependency/tcp'
require 'litmus_paper/health'
require 'litmus_paper/forced_health'
require 'litmus_paper/logger'
require 'litmus_paper/metric/available_memory'
require 'litmus_paper/metric/cpu_load'
require 'litmus_paper/service'
require 'litmus_paper/status_file'
require 'litmus_paper/version'

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
