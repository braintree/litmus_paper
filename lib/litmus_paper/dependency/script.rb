module LitmusPaper
  module Dependency
    class Script < Base
      attr_reader :script_pid

      def initialize(command, options = {})
        @command = command
        @timeout = options.fetch(:timeout, 5)
        @report_result = options.fetch(:report_result, false)
      end

      def available?
        super do
          begin
            Timeout.timeout(@timeout) do
              script_stdout = script_stderr = nil
              script_status = POpen4.popen4(@command) do |stdout, stderr, stdin, pid|
                @script_pid = pid
                script_stdout = stdout.read.strip
                script_stderr = stderr.read.strip
              end
              unless script_status.success?
                LitmusPaper.logger.info("Available check to #{@command} failed with status #{$CHILD_STATUS.exitstatus}")
                LitmusPaper.logger.info("Failed stdout: #{script_stdout}")
                LitmusPaper.logger.info("Failed stderr: #{script_stderr}")
              end
              @result = script_stdout if @report_result
              script_status.success?
            end
          rescue Timeout::Error
            LitmusPaper.logger.info("Timeout running command: '#{@command}'")
            kill_and_reap_script(@script_pid)
            false
          rescue => e
            LitmusPaper.logger.info("Available check to #{@uri} failed with #{e.message}")
            false
          end
        end
      end

      def kill_and_reap_script(pid)
        Process.kill(9, pid)
        stop_time = Time.now + 2
        while Time.now < stop_time
          if Process.waitpid(pid, Process::WNOHANG)
            LitmusPaper.logger.info("Reaped PID #{pid}")
            return
          else
            sleep 0.1
          end
        end
        LitmusPaper.logger.error("Unable to reap PID #{pid}")
      rescue Errno::ESRCH
        LitmusPaper.logger.info("Attempted to kill non-existent PID #{pid} (ESRCH)")
      rescue Errno::ECHILD
        LitmusPaper.logger.info("Attempted to reap PID #{pid} but it has already been reaped (ECHILD)")
      end

      def to_s
        "Dependency::Script(#{@command})"
      end

      def result
        return super unless @report_result
        @result[0...100] if @result
      end
    end
  end
end
