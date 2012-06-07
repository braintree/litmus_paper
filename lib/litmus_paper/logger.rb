module LitmusPaper
  class Logger
    extend Forwardable
    # def_delegators :EM, :debug, :info

    def write(message)
      puts message
    end

    def info(message)
      write(message)
    end

    def debug(message)
      write(message)
    end

    def setup!
      # EM.syslog_setup('0.0.0.0', 514)
    end
  end
end
