require 'net/http'
require 'uri'

require 'bundler/setup'
require 'facter'
require 'sinatra'

require 'ipvs_litmus/app'
require 'ipvs_litmus/hardware'
require 'ipvs_litmus/health'
require 'ipvs_litmus/http_check'

module IPVSLitmus
  def self.services
    @services ||= {}
  end
end
