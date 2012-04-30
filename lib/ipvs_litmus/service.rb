module IPVSLitmus
  class Service
    def initialize(name, dependencies, checks)
      @name = name
      @dependencies = dependencies
      @checks = checks
    end

    def success?
      health > 0
    end

    def current_health
      forced_health = _determine_forced_health
      return forced_health unless forced_health.nil?

      health = IPVSLitmus::Health.new
      @dependencies.each do |dependency|
        health.ensure(dependency)
      end

      @checks.each do |check|
        health.perform(check)
      end
      health
    end

    def _determine_forced_health
      if File.exists?(_down_file)
        ForcedHealth.new(0, File.read(_down_file).chomp)
      elsif File.exists?(_up_file)
        ForcedHealth.new(100, File.read(_up_file).chomp)
      else
        nil
      end
    end

    def _down_file
      IPVSLitmus.config_dir.join('down', @name)
    end

    def _up_file
      IPVSLitmus.config_dir.join('up', @name)
    end

  end
end
