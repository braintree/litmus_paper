require 'fileutils'
require 'tempfile'
require 'yaml'

module LitmusPaper
  class Cache
    def initialize(location, namespace, ttl)
      @path = File.join(location, namespace)
      @ttl = ttl

      FileUtils.mkdir_p(@path)
    end

    def set(key, value)
      return unless @ttl > 0
      filename = File.join(@path, key)
      if File.exist?(filename)
        File.open(filename, "r+") do |f|
          f.flock(File::LOCK_EX)
          f.rewind
          f.write(_entry(@ttl, value))
          f.flush
          f.truncate(f.pos)
        end
      else
        temp = Tempfile.new("#{key}_init", @path)
        begin
          temp.write(_entry(@ttl, value))
          temp.flush
        ensure
          temp.close
        end
        FileUtils.mv(temp.path, filename)
      end
    end

    def get(key)
      return unless File.exists?(File.join(@path, key))
      File.open(File.join(@path, key), "r") do |f|
        f.flock(File::LOCK_SH)
        entry = f.read
        expires_at, value = entry.split(" ", 2)
        expires_at.to_f < Time.now.to_f ? nil : YAML::load(value)
      end
    end

    def _entry(ttl, value)
      "#{Time.now.to_f + ttl} #{YAML::dump(value)}"
    end
  end
end
