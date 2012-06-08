module LitmusPaper
  class Logger
    extend Forwardable
    def_delegators :EM, :debug, :info

    def write(message)
      info(message)
    end

    def setup!
      # @file = File.open("/tmp/error", "w")
      EM.syslog_setup('0.0.0.0', 514)
    end
  end
end
