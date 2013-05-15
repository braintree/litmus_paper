module LitmusPaper
  module Dependency
    class Script
      attr_reader :script_pid

      def initialize(command, options = {})
        @command = command
        @timeout = options.fetch(:timeout, 5)
      end

      def available?
        SystemTimer.timeout_after(@timeout) do
          script_stdout = script_stderr = nil
          script_status = POpen4.popen4(@command) do |stdout, stderr, stdin, pid|
            @script_pid = pid
            script_stdout = stdout.read.strip
            script_stderr = stderr.read.strip
          end
          unless script_status.success?
            LitmusPaper.logger.info("Available check to #{@command} failed with status #{$CHILD_STATUS.exitstatus}")
            LitmusPaper.logger.info("Failed stdout #{script_stdout}")
            LitmusPaper.logger.info("Failed stderr #{script_stderr}")
          end
          script_status.success?
        end
      rescue Timeout::Error
        LitmusPaper.logger.info("Available check to '#{@command}' timed out")
        Process.kill(9, @script_pid) rescue Errno::ESRCH
        reap_zombies
        false
      end

      def reap_zombies
        stop_time = Time.now + 2
        while Time.now < stop_time
          if Process.waitpid(@script_pid, Process::WNOHANG)
            LitmusPaper.logger.info("Reaped PID #{@script_pid}")
            return
          else
            sleep 0.1
          end
        end
        LitmusPaper.logger.error("Unable to reap PID #{@script_pid}")
      rescue Errno::ECHILD
      end

      def to_s
        "Dependency::Script(#{@command})"
      end
    end
  end
end
