# Ruby's stock DNS resolution, by default, blocks the entire Ruby VM from
# processing while the lookup is happening, because it calls out to the native
# libc resolver code. A slow DNS server can cause your entire Ruby process to
# grind to a halt. Ruby comes with a pure Ruby replacement that is not loaded
# by default called 'resolv'.
#
# 'resolv-replace' monkeypatches the various Ruby Socket objects to use resolv
#
require 'resolv-replace'
require 'net/http'
require 'net/https'
require 'uri'
require 'forwardable'

require 'remote_syslog_logger'

require 'litmus_paper/cache'
require 'litmus_paper/configuration'
require 'litmus_paper/configuration_file'
require 'litmus_paper/dependency/file_contents'
require 'litmus_paper/dependency/haproxy_backends'
require 'litmus_paper/dependency/http'
require 'litmus_paper/dependency/script'
require 'litmus_paper/dependency/tcp'
require 'litmus_paper/health'
require 'litmus_paper/logger'
require 'litmus_paper/metric/big_brother_service'
require 'litmus_paper/metric/constant_metric'
require 'litmus_paper/metric/cpu_load'
require 'litmus_paper/metric/haproxy_weight'
require 'litmus_paper/metric/internet_health'
require 'litmus_paper/metric/script'
require 'litmus_paper/service'
require 'litmus_paper/status_file'
require 'litmus_paper/util'
require 'litmus_paper/version'

module LitmusPaper
  class << self
    extend Forwardable
    def_delegators :@config, :services, :data_directory, :port, :cache_location, :cache_ttl
    attr_accessor :logger
  end

  self.logger = Logger.new

  def self.check_service(service_name)
    if service = services[service_name]
      service.current_health
    else
      nil
    end
  end

  def self.configure(filename = nil)
    @config_file = if filename
      filename
    elsif ENV['LITMUS_CONFIG'] && File.exists?(ENV['LITMUS_CONFIG'])
      ENV['LITMUS_CONFIG']
    elsif File.exists?('/etc/litmus.conf')
      '/etc/litmus.conf'
    else
      raise "No litmus configuration file"
    end
    @config = LitmusPaper::ConfigurationFile.new(@config_file).evaluate
  end

  def self.reload
    LitmusPaper.logger.info "Reloading configuration"
    begin
      configure(@config_file)
    rescue Exception => e
      LitmusPaper.logger.error "Problem reloading config: #{e.message}"
      LitmusPaper.logger.error e.backtrace.join("\n")
    end
  end
end

Signal.trap("HUP") { LitmusPaper.reload }
