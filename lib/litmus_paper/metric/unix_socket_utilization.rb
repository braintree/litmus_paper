require 'raindrops'

module LitmusPaper
  module Metric
    class UnixSocketUtilitization
      def initialize(weight, socket_path, maxconn)
        @weight = weight
        @socket_path = socket_path
        @maxconn = maxconn
        @active = 0
        @queued = 0
      end

      def current_health
        stats = _stats
        @active = stats.active
        @queued = stats.queued
        if @queued == 0
          return @weight
        else
          return [
            @weight - (
              (@weight * @active.to_f) / (3 * @maxconn.to_f) +
              (2 * @weight * @queued.to_f) / (3 * @maxconn.to_f)
            ), 1
          ].max
        end
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
