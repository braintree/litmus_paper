require 'raindrops'

module LitmusPaper
  module Metric
    class TcpSocketUtilization < SocketUtilization
      attr_reader :address

      def initialize(weight, address, maxconn)
        super(weight, maxconn)
        @address = address
      end

      def _stats
        Raindrops::Linux.tcp_listener_stats([address])[address]
      end

      def to_s
        current_stats = stats
        active = current_stats[:socket_active]
        queued = current_stats[:socket_queued]
        utilization = current_stats[:socket_utilization]

        "Metric::TcpSocketUtilization(weight: #{weight}, maxconn: #{maxconn}, active: #{active}, queued: #{queued}, utilization: #{utilization}, address: #{address})"
      end
    end
  end
end
