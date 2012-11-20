module LitmusPaper
  module Dependency
    class Script
      def initialize(command, options = {})
        @command = command
        @timeout = options.fetch(:timeout, 5)
      end

      def available?
        Timeout.timeout(@timeout) do
          %x[#{@command}]
          $CHILD_STATUS.success?
        end
      rescue Timeout::Error
        false
      end

      def to_s
        "Dependency::Script(#{@command})"
      end
    end
  end
end
