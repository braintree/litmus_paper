require 'bundler/setup'
require 'sinatra'

require 'ipvs_litmus/version'
require 'ipvs_litmus/app'

module IPVSLitmus
  def self.services
    @services ||= {}
  end
end
