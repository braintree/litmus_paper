require 'raindrops'

module LitmusPaper
  module Metric
    class UnixSocketUtilitization
      def initialize(weight, socket_path, maxconn)
        @weight = weight
        @socket_path = socket_path
        @maxconn = maxconn
      end

      def current_health
        stats = _stats

        if stats.queued == 0
          return @weight
        end

        [
          @weight - (
            (@weight * stats.active.to_f) / (3 * @maxconn.to_f) +
            (2 * @weight * stats.queued.to_f) / (3 * @maxconn.to_f)
          ),
          1
        ].max
      end

      def stats
        stats = _stats

        {
          :socket_active => stats.active,
          :socket_queued => stats.queued,
          :socket_utilization => ((stats.queued / @maxconn.to_f) * 100).round,
        }
      end

      def _stats
        Raindrops::Linux.unix_listener_stats([@socket_path])[@socket_path]
      end

      def to_s
        "Metric::UnixSocketUtilitization(weight: #{@weight}, maxconn: #{@maxconn}, active: #{@active.to_i}, queued: #{@queued.to_i}, path: #{@socket_path})"
      end
    end
  end
end
