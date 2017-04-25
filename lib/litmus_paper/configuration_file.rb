module LitmusPaper
  class ConfigurationFile
    def initialize(config_file_path)
      @config_file_path = config_file_path
      @services = {}
      @port = 9292
      @data_directory = "/etc/litmus"
    end

    def evaluate_yaml(config_contents)
      config = YAML.load(config_contents)

      if glob_pattern = config["include_files"]
        include_files(glob_pattern)
      end

      @data_directory = config.fetch("data_directory", @data_directory)
      @port = config.fetch("port", @port)

      (config["services"] || []).each do |service_name, service_configuration|
        s = Service.new(service_name)

        (service_configuration["dependencies"] || []).each do |dependency_name, dependency_args|
          dependency_class = LitmusPaper::Dependency.const_get(dependency_name)
          s.depends dependency_class, dependency_args
        end

        service_configuration["metrics"].each do |metric_name, metric_args|
          metric_class = LitmusPaper::Metric.const_get(metric_name)
          s.measure_health metric_class, metric_args
        end

        @services[service_name] = s
      end
    end

    def evaluate(file = @config_file_path)
      LitmusPaper.logger.info "Loading file #{file}"
      config_contents = File.read(file)
      if File.extname(file) == ".yaml"
        evaluate_yaml(config_contents)
      else
        instance_eval(config_contents)
      end
      LitmusPaper::Configuration.new(@port, @data_directory, @services)
    end

    def include_files(glob_pattern)
      full_glob_pattern = File.expand_path(glob_pattern, File.dirname(@config_file_path))
      LitmusPaper.logger.info "Searching for files matching: #{full_glob_pattern}"

      Dir.glob(full_glob_pattern).each do |file|
        evaluate(file)
      end
    end

    def port(port)
      @port = port
    end

    def data_directory(directory)
      @data_directory = directory
    end

    def service(name, &block)
      service = Service.new(name.to_s)
      block.call(service)
      @services[name.to_s] = service
    end
  end
end
