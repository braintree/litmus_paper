module LitmusPaper
  class Logger
    extend Forwardable
    def_delegators :@syslog, :debug, :info, :error

    def initialize
      @syslog = RemoteSyslogLogger.new('127.0.0.1', 514, :program => 'litmus_paper', :facility => 'daemon')
    end

    def write(message)
      @syslog.info(message)
    end

  end
end
