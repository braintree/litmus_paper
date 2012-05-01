module IPVSLitmus
  module CLI
    class Server < Rack::Server
      class Options
        def parse!(args)
          args, options = args.dup, {}

          opt_parser = OptionParser.new do |opts|
            opts.banner = "Usage: litmus server [mongrel, thin, etc] [options]"
            opts.on("-c", "--config=file", String,
                    "Litmus configuration file", "Default: /etc/litmus.conf") { |v| options[:litmus_config] = v }
            opts.on("-D", "--data-dir=path", String,
                    "Litmus data directory", "Default: /etc/litmus") { |v| options[:config_dir] = v }

            opts.separator ""

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

      def start
        IPVSLitmus.configure(options[:litmus_config])
        IPVSLitmus.config_dir = options[:config_dir]
        super
      end

      def default_options
        super.merge(
          :litmus_config => '/etc/litmus.conf',
          :config_dir => '/etc/litmus'
        )
      end
    end
  end
end
