module LitmusPaper
  module Dependency
    class TCP
      def initialize(ip, port, options = {})
        @ip, @port = ip, port
        @timeout = options.fetch(:timeout_seconds, 5)
      end

      def available?
        SystemTimer.timeout_after(@timeout) do
          socket = TCPSocket.new(@ip, @port)
          socket.close
        end
        true
      rescue Exception => e
        LitmusPaper.logger.info("TCP available check to #{@ip}:#{@port} failed with #{e.message}")
        false
      end

      def to_s
        "Dependency::TCP(tcp://#{@ip}:#{@port})"
      end
    end
  end
end

