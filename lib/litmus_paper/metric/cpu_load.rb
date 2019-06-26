module LitmusPaper
  module Metric
    class CPULoad
      def initialize(weight)
        @weight = weight
      end

      def current_health
        [@weight - (@weight * load_average / processor_count), 1].max
      end

      def processor_count
        @processor_count ||= File.readlines('/proc/cpuinfo').reduce(0) do |memo, line|
          if line =~ /^processor/
            memo + 1
          else
            memo
          end
        end

      end

      def load_average
        File.read('/proc/loadavg').split(' ').first.to_f
      end

      def stats
        {
          :cpu_load_average => load_average,
        }
      end

      def to_s
        "Metric::CPULoad(#{@weight})"
      end
    end
  end
end
