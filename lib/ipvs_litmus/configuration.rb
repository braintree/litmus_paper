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
      service = Service.new(name.to_s)
      block.call(service)
      @services[name.to_s] = service
    end
  end
end
