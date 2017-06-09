$LOAD_PATH.unshift File.expand_path('lib', File.dirname(__FILE__))
require 'litmus_paper'
require 'litmus_paper/app'

LitmusPaper.configure
use Rack::CommonLogger, LitmusPaper.logger
run LitmusPaper::App
