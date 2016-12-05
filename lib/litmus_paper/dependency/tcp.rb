module LitmusPaper
  module Dependency
    class TCP < Base
      def initialize(ip, port, options = {})
        @ip, @port = ip, port
        @timeout = options.fetch(:timeout_seconds, 5)
        @input_data = options[:input_data]
        @expected_output = options[:expected_output]
      end

      def available?
        super do
          begin
            response = true

            Timeout.timeout(@timeout) do
              socket = TCPSocket.new(@ip, @port)
              if @expected_output
                socket.puts(@input_data) if @input_data
                data = socket.gets
                response = data.chomp == @expected_output
                LitmusPaper.logger.info("Response (#{response}) does not match expected output (#{@expected_output})")
              end
              socket.close
            end

            response
          rescue Timeout::Error
            LitmusPaper.logger.info("Timeout connecting #{@ip}:#{@port}")
            false
          rescue => e
            LitmusPaper.logger.info("TCP available check to #{@ip}:#{@port} failed with #{e.message}")
            false
          end
        end
      end

      def to_s
        "Dependency::TCP(tcp://#{@ip}:#{@port})"
      end
    end
  end
end

