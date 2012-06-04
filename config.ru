$LOAD_PATH.unshift File.expand_path('lib', File.dirname(__FILE__))
require 'litmus_paper'

use Rack::CommonLogger, LitmusPaper.logger
run LitmusPaper::App
