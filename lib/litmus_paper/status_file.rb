module LitmusPaper
  class StatusFile
    attr_reader :health

    def self.global_down_file
      new("global_down", 0)
    end

    def self.global_up_file
      new("global_up", 100)
    end

    def self.service_down_file(service_name)
      new("#{service_name}_down", 0)
    end

    def self.service_up_file(service_name)
      new("#{service_name}_up", 100)
    end

    def self.priority_check_order_for_service(service_name)
      [
        global_down_file,
        global_up_file,
        service_down_file(service_name),
        service_up_file(service_name)
      ]
    end

    def initialize(filename, health)
      @path = File.join(LitmusPaper.config_dir, filename)
      @health = health
    end

    def content
      File.read(@path).chomp
    end

    def create(reason)
      FileUtils.mkdir_p(File.dirname(@path))
      File.open(@path, 'w') do |file|
        file.puts(reason)
      end
    end

    def delete
      FileUtils.rm(@path)
    end

    def exists?
      File.exists?(@path)
    end
  end
end
