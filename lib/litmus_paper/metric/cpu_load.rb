module LitmusPaper
  module Metric
    class CPULoad
      def initialize(weight, facter = Facter)
        @weight = weight
        @facter = facter
      end

      def current_health
        [@weight - (@weight * load_average / processor_count), 1].max
      end

      def processor_count
        @processor_count ||= @facter.value('processorcount').to_i
      end

      def load_average
        @facter.value('loadaverage').split(' ').first.to_f
      end

      def to_s
        "Metric::CPULoad(#{@weight})"
      end
    end
  end
end
