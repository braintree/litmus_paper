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
        else
          return [
            @weight - (
              (@weight * _stats.active.to_f) / (3 * @maxconn.to_f) +
              (2 * @weight * _stats.queued.to_f) / (3 * @maxconn.to_f)
            ), 1
          ].max
        end
      end

      def _stats
        Raindrops::Linux.unix_listener_stats([@socket_path])[@socket_path]
      end

      def to_s
        "Metric::UnixSocketUtilitization(weight: #{@weight}, maxconn: #{@maxconn}, path: #{@socket_path})"
      end
    end
  end
end
