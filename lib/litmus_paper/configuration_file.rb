require 'yaml'

module LitmusPaper
  class ConfigurationFile
    def initialize(config_file_path)
      @config_file_path = config_file_path
      @services = {}
      @port = 9292
      @data_directory = "/etc/litmus"
      @cache_location = "/run/shm"
      @cache_ttl = -1
    end

    def evaluate(file = @config_file_path)
      LitmusPaper.logger.info "Loading file #{file}"
      config_contents = File.read(file)
      if file =~ /\.(yaml|yml)/
        load_yaml(config_contents)
      else
        instance_eval(config_contents)
      end
      LitmusPaper::Configuration.new(
        @port,
        @data_directory,
        @services,
        @cache_location,
        @cache_ttl
      )
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

    def yaml_service(value)
      value.each do |name, config|
        config = Util.symbolize_keys(config)
        dependencies = parse_yaml_dependencies(config.fetch(:dependencies, []))
        checks = parse_yaml_checks(config.fetch(:checks, []))
        service = Service.new(name.to_s, dependencies, checks)
        @services[name.to_s] = service
      end
    end

    def parse_yaml_checks(config)
      config.map do |check|
        check_config = Util.symbolize_keys(check)
        case check[:type].to_sym
          when :big_brother_service
            Metric::BigBrotherService.new(check_config.delete(:service))
          when :cpu_load
            Metric::CPULoad.new(check_config.delete(:weight))
          when :constant_metric
            Metric::ConstantMetric.new(check_config.delete(:weight))
          when :internet_health
            weight = check_config.delete(:weight)
            hosts = check_config.delete(:hosts)
            Metric::InternetHealth.new(weight, hosts, check_config)
          when :script
            command = check_config.delete(:command)
            weight = check_config.delete(:weight)
            Metric::Script.new(command, weight, check_config)
          when :haproxy_backends_health
            weight = check_config.delete(:weight)
            domain_socket = dep_config.delete(:domain_socket)
            cluster = dep_config.delete(:cluster)
            Metric::HaproxyBackendsHealth.new(weight, domain_socket, cluster, check_config)
          when :tcp_socket_utilization
            weight = check_config.delete(:weight)
            address = check_config.delete(:address)
            maxconn = check_config.delete(:maxconn)
            Metric::TcpSocketUtilization.new(weight, address, maxconn)
          when :unix_socket_utilization
            weight = check_config.delete(:weight)
            socket_path = check_config.delete(:socket_path)
            maxconn = check_config.delete(:maxconn)
            Metric::UnixSocketUtilization.new(weight, socket_path, maxconn)
        end
      end
    end

    def parse_yaml_dependencies(config)
      config.map do |dep|
        dep_config = Util.symbolize_keys(dep)
        case dep[:type].to_sym
          when :file_contents
            path = dep_config.delete(:path)
            regex = dep_config.delete(:regex)
            Dependency::FileContents.new(path, regex, dep_config)
          when :haproxy_backends
            domain_socket = dep_config.delete(:domain_socket)
            cluster = dep_config.delete(:cluster)
            Dependency::HaproxyBackends.new(domain_socket, cluster, dep_config)
          when :http
            uri = dep_config.delete(:uri)
            Dependency::HTTP.new(uri, dep_config)
          when "script"
            command = dep_config.delete(:command)
            Dependency::Script.new(command, options)
          when "tcp"
            ip = dep_config.delete(:ip)
            port = dep_config.delete(:port)
            Dependency::TCP.new(ip, port, dep_config)
        end
      end
    end

    def cache_location(location)
      @cache_location = location
    end

    def cache_ttl(ttl)
      @cache_ttl = ttl
    end

    def load_yaml(contents)
      config = Util.symbolize_keys(YAML.load(contents))

      config.each do |key, value|
        case key
        when :include_files, :data_directory, :cache_location, :cache_ttl, :port
          send(key, value)
        when :services
          yaml_service(value)
        end
      end
    end
  end
end
