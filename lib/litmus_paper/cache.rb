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
      filepath = File.join(@path, key)
      begin
        File.open(filepath, "r+") do |f|
          f.flock(File::LOCK_EX)
          f.rewind
          f.write("#{Time.now.to_f + @ttl} #{YAML::dump(value)}")
          f.flush
          f.truncate(f.pos)
        end
      rescue Errno::ENOENT => e
        File.open(filepath, "a") {}
        set(key, value)
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
  end
end
