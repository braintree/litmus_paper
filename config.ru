$LOAD_PATH.unshift File.expand_path('lib', File.dirname(__FILE__))
require 'ipvs_litmus'

run IpvsLitmus::App
