require 'pathname'
require 'net/http'
require 'uri'

require 'bundler/setup'
require 'sinatra'

require 'facter'
require 'facts/loadaverage'

require 'ipvs_litmus/app'
require 'ipvs_litmus/dependency/http'
require 'ipvs_litmus/health'
require 'ipvs_litmus/forced_health'
require 'ipvs_litmus/metric/available_memory'
require 'ipvs_litmus/metric/cpu_load'
require 'ipvs_litmus/service'

module IPVSLitmus
  def self.services
    @services ||= {}
  end

  def self.config_dir
    @config_dir
  end

  def self.config_dir=(path)
    @config_dir = Pathname.new(path)
  end
end
