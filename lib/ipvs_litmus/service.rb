module IPVSLitmus
  class Service
    def initialize(dependencies, checks)
      @dependencies = dependencies
      @checks = checks
    end

    def success?
      health > 0
    end

    def health
      return 0 unless @dependencies.all?(&:available?)

      @checks.inject(0) do |health, check|
        health += check.health
      end
    end
  end
end
