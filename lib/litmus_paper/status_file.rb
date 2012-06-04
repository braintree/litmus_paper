module LitmusPaper
  class StatusFile
    def initialize(*filenames)
      @path = File.join(LitmusPaper.config_dir, *filenames)
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
