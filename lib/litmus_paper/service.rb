module LitmusPaper
  class Service
    attr_reader :checks

    def initialize(name, dependencies = [], checks = [])
      @name = name
      @dependencies = dependencies
      @checks = checks
    end

    def current_health
      forced_health = _determine_forced_health

      health = forced_health ? forced_health : LitmusPaper::Health.new
      @dependencies.each do |dependency|
        health.ensure(dependency)
      end

      @checks.each do |check|
        health.perform(check)
      end
      health
    end

    def measure_health(metric_class, options)
      @checks << metric_class.new(options[:weight])
    end

    def measure_health_with_args(metric_class, *args)
      @checks << metric_class.new(*args)
    end

    def depends(dependency_class, *args)
      @dependencies << dependency_class.new(*args)
    end

    def _health_files
      StatusFile.priority_check_order_for_service(@name)
    end

    def _determine_forced_health
      _health_files.map do |status_file|
        LitmusPaper::Health.new(status_file.forced, status_file.content) if status_file.exists?
      end.compact.first
    end
  end
end
