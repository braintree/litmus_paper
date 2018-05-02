module LitmusPaper
  module Metric
    class HaproxyWeightMetric
      def initialize(domain_socket, cluster, options = {})
        @haproxy_backends = Dependency::HaproxyBackends.new(domain_socket, cluster, options)

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
