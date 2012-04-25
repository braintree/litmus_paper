module IPVSLitmus
  module Metric
    class AvailableMemory
      MULTIPLIER = {
        "GB" => 1024*1024*1024,
        "MB" => 1024*1024,
        "KB" => 1024
      }

      def initialize(weight, facter = Facter)
        @weight = weight
        @facter = facter
      end

      def current_health
        @weight * memory_free / memory_total
      end

      def memory_total
        size, scale = @facter.value('memorytotal').split(' ')
        size.to_i * MULTIPLIER[scale]
      end

      def memory_free
        size, scale = @facter.value('memoryfree').split(' ')
        size.to_i * MULTIPLIER[scale]
      end
    end
  end
end
