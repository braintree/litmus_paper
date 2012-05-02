require 'pathname'
require 'net/http'
require 'uri'

require 'sinatra/base'
require 'facter'

require 'facts/loadaverage'

require 'ipvs_litmus/app'
require 'ipvs_litmus/configuration'
require 'ipvs_litmus/dependency/http'
require 'ipvs_litmus/health'
require 'ipvs_litmus/forced_health'
require 'ipvs_litmus/metric/available_memory'
require 'ipvs_litmus/metric/cpu_load'
require 'ipvs_litmus/service'
require 'ipvs_litmus/status_file'

module IPVSLitmus
  class << self
    attr_reader :services, :config_dir
  end

  def self.configure(filename)
    @config_file = filename
    @services = IPVSLitmus::Configuration.new(filename).evaluate
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

Signal.trap("HUP") { IPVSLitmus.reload }
