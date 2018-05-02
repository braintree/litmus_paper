module LitmusPaper
  module Metric
    class HaproxyWeight
      def initialize(socket, backend, options = {})
        options[:timeout_seconds] = options.fetch(:timeout, 2)
        @haproxy_backends = Dependency::HaproxyBackends.new(socket, backend, options)
      end

      def current_health
        @haproxy_backends.average_weight
      end

      def to_s
        "Metric::HaproxyWeight(#{@haproxy_backends})"
      end
    end
  end
end
