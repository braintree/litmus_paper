module LitmusPaper
  module Dependency
    class Script
      def initialize(command, options = {})
        @command = command
        @timeout = options.fetch(:timeout, 5)
      end

      def available?
        Timeout.timeout(@timeout) do
          output = %x[#{@command}]
          unless $CHILD_STATUS.success?
            LitmusPaper.logger.info("Available check to #{@command} failed with status #{$CHILD_STATUS.exitstatus}")
            LitmusPaper.logger.info("Failed output #{output}")
          end
          $CHILD_STATUS.success?
        end
      rescue Timeout::Error
        LitmusPaper.logger.info("Available check to '#{@command}' timed out")
        false
      end

      def to_s
        "Dependency::Script(#{@command})"
      end
    end
  end
end
