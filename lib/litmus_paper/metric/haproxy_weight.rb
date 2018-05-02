module LitmusPaper
  module Metric
    class HaproxyWeight
      def initialize(weight, socket, backend, options = {})
        @weight = weight
        @socket = socket
        @backend = backend
        options[:timeout_seconds] = options.fetch(:timeout, 2)
        @haproxy_backends = Dependency::HaproxyBackends.new(socket, backend, options)
      end

      def current_health
        @weight * @haproxy_backends.average_weight / 100
      end

      def to_s
        "Metric::HaproxyWeight(#{@weight}, #{@socket}, #{@backend})"
      end
    end
  end
end
