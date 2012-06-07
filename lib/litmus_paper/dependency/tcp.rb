module LitmusPaper
  module Dependency
    class TCP
      class EndpointAvailable < EM::Connection
        def initialize(fiber, timeout)
          @fiber = fiber
          EM.add_timer(timeout, method(:connection_timeout))
        end

        def connection_completed
          close_connection
          @fiber.resume(true)
        end

        def connection_timeout
          @fiber.resume(false)
        end
      end

      def initialize(ip, port, options = {})
        @ip, @port = ip, port
        @timeout = options.fetch(:timeout, 2)
      end

      def available?
        fiber = Fiber.current

        EM.connect(@ip, @port, EndpointAvailable, fiber, @timeout) do |connection|
          connection.set_pending_connect_timeout @timeout
        end

        return Fiber.yield
      end

      def to_s
        "Dependency::TCP(tcp://#{@ip}:#{@port})"
      end
    end
  end
end

