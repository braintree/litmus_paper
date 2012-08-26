module LitmusPaper
  module Metric
    class BigBrotherService
      def initialize(service)
        @service = service
      end

      def current_health
        status = Net::HTTP.get('127.0.0.1', "/cluster/#{@service}", 9292)
        if status =~ /CombinedWeight: (\d+)/m
          $1.to_i
        else
          0
        end
      end

      def to_s
        "Metric::BigBrotherService(#{@service})"
      end
    end
  end
end
