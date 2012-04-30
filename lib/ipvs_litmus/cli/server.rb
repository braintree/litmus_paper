module IPVSLitmus
  module CLI
    class Server < Rack::Server
      class Options
        def parse!(args)
          args, options = args.dup, {}

          opt_parser = OptionParser.new do |opts|
            opts.banner = "Usage: litmus server [mongrel, thin, etc] [options]"
            opts.on("-p", "--port=port", Integer,
                    "Runs Litmus on the specified port.", "Default: 9292") { |v| options[:Port] = v }
            opts.on("-b", "--binding=ip", String,
                    "Binds Litmus to the specified ip.", "Default: 0.0.0.0") { |v| options[:Host] = v }
            opts.on("-d", "--daemon", "Make server run as a Daemon.") { options[:daemonize] = true }
            opts.on("-P","--pid=pid",String,
                    "Specifies the PID file.",
                    "Default: rack.pid") { |v| options[:pid] = v }

            opts.separator ""

            opts.on("-h", "--help", "Show this help message.") { puts opts; exit }
          end

          opt_parser.parse! args

          options[:server] = args.shift
          options
        end
      end

      def opt_parser
        Options.new
      end
    end
  end
end
