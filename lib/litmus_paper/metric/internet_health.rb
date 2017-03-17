module LitmusPaper
  module Metric
    class InternetHealth
      def initialize(hosts, options = {})
        @hosts = hosts
        @options = options
        @timeout = options.fetch(:timeout_seconds, 5)
      end

      def tcp_connect?(host, port)
        Timeout.timeout(@timeout) do
          socket = TCPSocket.new(host, port)
          socket.close
        end
        true
      rescue Timeout::Error
        LitmusPaper.logger.info("Timeout connecting to #{host}:#{port}")
        false
      rescue => e
        LitmusPaper.logger.info("TCP connect to #{host}:#{port} failed with #{e.message}")
        false
      end

      def current_health
        health = 100 * @hosts.reduce(Rational(0)) do |memo, host|
          if tcp_connect?(*host.split(':'))
            memo += Rational(1) / Rational(@hosts.length)
          end
          memo
        end
        health.to_i
      end

      def to_s
        "Metric::InternetHealth(#{@hosts.inspect}, #{@options.inspect})"
      end
    end
  end
end
