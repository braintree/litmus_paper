require 'pathname'
require 'net/http'
require 'net/https'
require 'uri'
require 'forwardable'

# Ruby’s stock DNS resolution, by default, blocks the entire Ruby VM from
# processing while the lookup is happening, because it calls out to the native
# libc resolver code. A slow DNS server can cause your entire Ruby process to
# grind to a halt. Ruby comes with a pure Ruby replacement that is not loaded
# by default called 'resolv'.
#
# 'resolv-replace' monkeypatches the various Ruby Socket objects to use resolv
#
require 'resolv-replace'

require 'sinatra/base'
require 'facter'
require 'syslog_logger'

require 'facts/loadaverage'

require 'litmus_paper/app'
require 'litmus_paper/configuration'
require 'litmus_paper/configuration_file'
require 'litmus_paper/dependency/haproxy_backends'
require 'litmus_paper/dependency/http'
require 'litmus_paper/dependency/tcp'
require 'litmus_paper/health'
require 'litmus_paper/forced_health'
require 'litmus_paper/logger'
require 'litmus_paper/metric/available_memory'
require 'litmus_paper/metric/big_brother_service'
require 'litmus_paper/metric/cpu_load'
require 'litmus_paper/service'
require 'litmus_paper/status_file'
require 'litmus_paper/version'

module LitmusPaper
  class << self
    extend Forwardable
    def_delegators :@config, :services, :data_directory, :port
    attr_accessor :logger
  end

  self.logger = Logger.new

  def self.check_service(service_name)
    Facter.flush

    if service = services[service_name]
      service.current_health
    else
      nil
    end
  end

  def self.configure(filename)
    @config_file = filename

    begin
      @config = LitmusPaper::ConfigurationFile.new(filename).evaluate
    rescue Exception
    end
  end

  def self.reload
    LitmusPaper.logger.info "Reloading configuration"
    configure(@config_file)
  end
end

Signal.trap("USR1") { LitmusPaper.reload }
