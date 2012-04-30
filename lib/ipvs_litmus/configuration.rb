module IPVSLitmus
  class Configuration
    def initialize(config_file_path)
      @config_file_path = config_file_path
    end

    def evaluate
      config_contents = File.read(@config_file_path)
      @services = {}
      instance_eval(config_contents)
      @services
    end

    def service(name, &block)
      service = Service.new(name)
      block.call(service)
      @services[name] = service
    end
  end
end
