module IPVSLitmus
  class Service
    def initialize(dependencies, checks)
      @dependencies = dependencies
      @checks = checks
    end

    def success?
      health > 0
    end

    def current_health
      health = IPVSLitmus::Health.new
      @dependencies.each do |dependency|
        health.ensure(dependency)
      end

      @checks.each do |check|
        health.perform(check)
      end
      health
    end
  end
end
