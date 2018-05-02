module LitmusPaper
  module Metric
    class HaproxyWeightMetric
      def initialize(haproxy_backends)
        @haproxy_backends = haproxy_backends

      end

      def current_health
        @haproxy_backends.average_weight
      end

      def to_s
        "Metric::HaproxyWeightMetric(#{@haproxy_backends})"
      end
    end
  end
end
