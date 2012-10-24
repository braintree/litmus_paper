module LitmusPaper
  module CLI
    class Server < Rack::Server
      class Options
        def parse!(args)
          args, options = args.dup, {}

          opt_parser = OptionParser.new do |opts|
            opts.banner = "Usage: litmus [mongrel, thin, etc] [options]"
            opts.on("-c", "--config=file", String,
                    "Litmus configuration file", "Default: /etc/litmus.conf") { |v| options[:litmus_config] = v }
            opts.separator ""

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

          options[:config] = File.expand_path("../../../config.ru", File.dirname(__FILE__))
          options[:server] = args.shift
          options
        end
      end

      def opt_parser
        Options.new
      end

      def start
        if !File.exists?(options[:litmus_config])
          puts "Could not find #{options[:litmus_config]}. Specify correct location with -c file"
          exit 1
        end

        LitmusPaper.configure(options[:litmus_config])
        options[:Port] = LitmusPaper.port

        super
      end

      def default_options
        super.merge(
          :litmus_config => '/etc/litmus.conf'
        )
      end
    end
  end
end
