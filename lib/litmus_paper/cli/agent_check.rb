require 'optparse'
require 'litmus_paper/agent_check_server'

module LitmusPaper
  module CLI
    class AgentCheck

      def parse_args(args)
        options = {}
        options[:pid_file] = '/tmp/litmus-agent-check.pid'
        optparser = OptionParser.new do |opts|
          opts.on("-s", "--service SERVICE:PORT,...", Array, "agent-check service to port mappings") do |s|
            options[:services] = s
          end
          opts.on("-c", "--config CONFIG", "Path to litmus paper config file") do |c|
            options[:litmus_paper_config] = c
          end
          opts.on("-p", "--pid-file PID_FILE", String, "Where to write the pid") do |p|
            options[:pid_file] = p
          end
          opts.on("-w", "--workers WORKERS", Integer, "Number of worker processes") do |w|
            options[:workers] = w
          end
          opts.on("-D", "--daemonize", "Daemonize the process") do |d|
            options[:daemonize] = d
          end
          opts.on("-h", "--help", "Help text") do |h|
            options[:help] = h
          end
        end

        begin
          optparser.parse! args
        rescue OptionParser::InvalidOption => e
          puts e
          puts optparser
          exit 1
        end

        if options[:help]
          puts optparser
          exit 0
        end

        if !options.has_key?(:services)
          puts "Error: `-s SERVICE:PORT,...` required"
          puts optparser
          exit 1
        end

        if !options.has_key?(:workers) || options[:workers] <= 0
          puts "Error: `-w WORKERS` required, and must be greater than 0"
          puts optparser
          exit 1
        end

        options[:services] = options[:services].reduce({}) do |memo, service|
          if service.split(':').length == 2
            service, port = service.split(':')
            memo[port.to_i] = service
            memo
          else
            puts "Error: Incorrect service port arg `-s SERVICE:PORT,...`"
            puts optparser
            exit 1
          end
        end

        options
      end

      def run(args)
        options = parse_args(args)
        agent_check_server = LitmusPaper::AgentCheckServer.new(
          options[:litmus_paper_config],
          options[:services],
          options[:workers],
          options[:pid_file],
          options[:daemonize],
        )
        agent_check_server.run
      end

    end
  end
end
