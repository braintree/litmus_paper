require 'raindrops'

module LitmusPaper
  module Metric
    class SocketUtilization
      attr_reader :weight, :maxconn

      def initialize(weight, maxconn)
        @weight = weight
        @maxconn = maxconn
      end

      def current_health
        stats = _stats

        if stats.queued == 0
          return weight
        end

        [
          weight - (
            (weight * stats.active.to_f) / (3 * maxconn.to_f) +
            (2 * weight * stats.queued.to_f) / (3 * maxconn.to_f)
          ),
          1
        ].max
      end

      def stats
        stats = _stats

        {
          :socket_active => stats.active,
          :socket_queued => stats.queued,
          :socket_utilization => ((stats.queued / maxconn.to_f) * 100).round,
        }
      end

      def _stats
        raise "Sub-classes must implement _stats"
      end

      def to_s
        raise "Sub-classes must implement to_s"
      end
    end
  end
end
