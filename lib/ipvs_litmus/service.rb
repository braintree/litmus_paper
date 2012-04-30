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

    def _health_files
      @health_files ||= [
        [0, IPVSLitmus.config_dir.join('down', @name)],
        [100, IPVSLitmus.config_dir.join('up', @name)],
        [0, IPVSLitmus.config_dir.join('global_down')],
        [100, IPVSLitmus.config_dir.join('global_up')]
      ]
    end

    def _determine_forced_health
      _health_files.map do |health, file|
        ForcedHealth.new(health, File.read(file).chomp) if File.exists?(file)
      end.compact.first
    end
  end
end
