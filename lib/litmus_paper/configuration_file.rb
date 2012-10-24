module LitmusPaper
  class ConfigurationFile
    def initialize(config_file_path)
      @config_file_path = config_file_path
      @services = {}
      @port = 9292
      @data_directory = "/etc/litmus"
    end

    def evaluate(file = @config_file_path)
      LitmusPaper.logger.info "Loading file #{file}"
      config_contents = File.read(file)
      instance_eval(config_contents)
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
