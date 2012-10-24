module LitmusPaper
  class Logger
    extend Forwardable
    def_delegators :@syslog, :debug, :info, :error

    def initialize
      @syslog = SyslogLogger.new("litmus_paper")
    end

    def write(message)
      @syslog.info(message)
    end

  end
end
