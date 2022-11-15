require 'optparse'
require 'litmus_paper/single_port_agent_server'
require 'litmus_paper/multi_port_agent_server'

module LitmusPaper
  module CLI
    class AgentCheck

      def parse_args(args)
        options = {}
        options[:pid_file] = '/tmp/litmus-agent-check.pid'
        optparser = OptionParser.new do |opts|
          opts.on("-s", "--service SERVICE:PORT,...", Array, "agent-check service to port mappings (multi-port mode)") do |s|
            options[:services] = s
          end
          opts.on("-c", "--config CONFIG", "Path to litmus paper config file") do |c|
            options[:litmus_paper_config] = c
          end
          opts.on("-p", "--pid-file PID_FILE", String, "Where to write the pid") do |p|
            options[:pid_file] = p
          end
          opts.on("-P", "--port PORT", Integer, "Port for agent check. Can be used with HAProxy 1.7+ with agent-send directive (single-port mode)") do |port|
            options[:port] = port
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

        if !options.has_key?(:services) && !options.has_key?(:port)
          puts "Error: `-s SERVICE:PORT,...` or `-P PORT` required"
          puts optparser
          exit 1
        elsif options.has_key?(:services) && options.has_key?(:port)
          puts "Error: `-s` and `-P` are mutually exclusive and cannot be specified together"
          puts optparser
          exit 1
        end

        if !options.has_key?(:workers) || options[:workers] <= 0
          puts "Error: `-w WORKERS` required, and must be greater than 0"
          puts "  Use a value equal to the number of expected concurrent"
          puts "  agent checks from HAProxy"
          puts optparser
          exit 1
        end

        if options.has_key?(:services)
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
        end

        options
      end

      def run(args)
        options = parse_args(args)

        if options.has_key?(:port)
          agent_check_server = LitmusPaper::SinglePortAgentServer.new(
            options[:litmus_paper_config],
            options[:daemonize],
            options[:pid_file],
            options[:port],
            options[:workers],
          )
        else
          agent_check_server = LitmusPaper::MultiPortAgentServer.new(
            options[:litmus_paper_config],
            options[:daemonize],
            options[:pid_file],
            options[:services],
            options[:workers],
          )
        end

        agent_check_server.run
      end

    end
  end
end
