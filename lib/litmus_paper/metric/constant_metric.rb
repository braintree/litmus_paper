module LitmusPaper
  module Metric
    class ConstantMetric
      def initialize(weight)
        @weight = weight
      end

      def current_health
        @weight
      end

      def stats
        {}
      end

      def to_s
        "Metric::ConstantMetric(#{@weight})"
      end
    end
  end
end
