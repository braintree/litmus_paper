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

    def perform(check)
      @value += check.current_health
      @summary << "#{check.class}: #{check.current_health}\n"
    end

    def ensure(dependency)
      @dependencies_available &&= dependency.available?
      @summary << "#{dependency.class}: #{dependency.available? ? 'OK' : 'FAIL'}\n"
    end
  end
end
