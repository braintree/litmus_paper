module LitmusPaper
  class StatusFile
    attr_reader :forced

    def self.global_down_file
      new("global_down", :down)
    end

    def self.global_up_file
      new("global_up", :up)
    end

    def self.service_down_file(service_name)
      new("#{service_name}_down", :down)
    end

    def self.service_up_file(service_name)
      new("#{service_name}_up", :up)
    end

    def self.priority_check_order_for_service(service_name)
      [
        global_down_file,
        global_up_file,
        service_down_file(service_name),
        service_up_file(service_name)
      ]
    end

    def initialize(filename, forced)
      @path = File.join(LitmusPaper.data_directory, filename)
      @forced = forced
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
