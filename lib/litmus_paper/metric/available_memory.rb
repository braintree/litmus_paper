module LitmusPaper
  module Metric
    class AvailableMemory
      MULTIPLIER = {
        "GB" => 1024*1024*1024,
        "MB" => 1024*1024,
        "KB" => 1024
      }

      def initialize(weight, facter = DeferredFacter)
        @weight = weight
        @facter = facter
      end

      def current_health
        @weight * memory_free / memory_total
      end

      def memory_total
        return @memory_total unless @memory_total.nil?

        size, scale = @facter.value('memorytotal').split(' ')
        @memory_total = (size.to_f * MULTIPLIER[scale]).to_i
      end

      def memory_free
        size, scale = @facter.value('memoryfree').split(' ')
        (size.to_f * MULTIPLIER[scale]).to_i
      end

      def to_s
        "Metric::AvailableMemory(#{@weight})"
      end
    end
  end
end
