module IPVSLitmus
  class Health

    attr_reader :summary

    def initialize
      @value = 0
      @dependencies_available = true
      @summary = ""
    end

    def ok?
      value > 0
    end

    def value
      return 0 unless @dependencies_available
      @value
    end

    def perform(metric)
      health = metric.current_health

      @value += health
      @summary << "#{metric.class}: #{health}\n"
    end

    def ensure(dependency)
      available = dependency.available?

      @dependencies_available &&= available
      @summary << "#{dependency.class}: #{available ? 'OK' : 'FAIL'}\n"
    end
  end
end
