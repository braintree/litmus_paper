# vim: set ft=ruby
require 'remote_syslog_logger'

APP_ROOT = '/vagrant'

worker_processes 5
working_directory APP_ROOT

logger(RemoteSyslogLogger.new('127.0.0.1', 514, :program => 'litmus_paper', :facility => 'daemon'))

pid "/tmp/unicorn.pid"
