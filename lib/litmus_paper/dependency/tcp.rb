module LitmusPaper
  module Dependency
    class TCP
      def initialize(ip, port)
        @ip, @port = ip, port
      end

      def available?
        Timeout.timeout(5) do
          socket = TCPSocket.new(@ip, @port)
          socket.close
        end
        true
      rescue Exception
        false
      end

      def to_s
        "Dependency::TCP(tcp://#{@ip}:#{@port})"
      end
    end
  end
end

