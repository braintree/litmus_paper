module LitmusPaper
  module Dependency
    class FileContents
      def initialize(path, regex, options = {})
        @path = path
        @regex = regex
        @timeout = options.fetch(:timeout, 5)
      end

      def available?
        Timeout.timeout(@timeout) do
          if File.read(@path).match(@regex)
            true
          else
            LitmusPaper.logger.info("Available check of #{@path} failed, content did not match #{@regex.inspect}")
            false
          end
        end
      rescue Timeout::Error
        LitmusPaper.logger.info("Timeout reading #{@path}")
        false
      rescue => e
        LitmusPaper.logger.info("Error reading #{@path}: '#{e.message}'")
        false
      end

      def to_s
        "Dependency::FileContents(#{@path}, #{@regex.inspect})"
      end
    end
  end
end
