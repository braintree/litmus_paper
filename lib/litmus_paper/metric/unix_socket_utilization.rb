require 'raindrops'

module LitmusPaper
  module Metric
    class UnixSocketUtilization < SocketUtilization
      attr_reader :socket_path

      def initialize(weight, socket_path, maxconn)
        super(weight, maxconn)
        @socket_path = socket_path
      end

      def _stats
        Raindrops::Linux.unix_listener_stats([socket_path])[socket_path]
      end

      def to_s
        current_stats = stats
        active = current_stats[:socket_active]
        queued = current_stats[:socket_queued]
        utilization = current_stats[:socket_utilization]

        "Metric::UnixSocketUtilization(weight: #{weight}, maxconn: #{maxconn}, active: #{active}, queued: #{queued}, utilization: #{utilization}, path: #{socket_path})"
      end
    end

    def self.const_missing(const_name)
      super unless const_name == :UnixSocketUtilitization
      warn "`LitmusPaper::Metric::UnixSocketUtilitization` has been deprecated. Use `LitmusPaper::Metric::UnixSocketUtilization` instead."
      UnixSocketUtilization
    end
  end
end
