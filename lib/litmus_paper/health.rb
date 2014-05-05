module LitmusPaper
  class Health

    attr_reader :summary

    def initialize(forced = :none, summary = "")
      @value = 0
      @dependencies_available = true
      @summary = summary
      @forced = forced
    end

    def ok?
      value > 0
    end

    def forced?
      @forced != :none
    end

    def value
      if forced?
        return @forced == :up ? 100 : 0
      end

      measured_health
    end

    def measured_health
      return 0 unless @dependencies_available
      @value
    end

    def perform(metric)
      health = metric.current_health

      @value += health
      @summary << "#{metric}: #{health}\n"
    end

    def ensure(dependency)
      available = dependency.available?

      @dependencies_available &&= available
      @summary << "#{dependency}: #{available ? 'OK' : 'FAIL'}\n"
    end
  end
end
