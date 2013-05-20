module LitmusPaper
  module CLI
    class Server
      class Options
        def parse!(args)
          args, options = args.dup, {}
          options[:unicorn_config] = "/etc/litmus_unicorn.rb"
          options[:daemonize] = false
          options[:Host] = "0.0.0.0"
          options[:Port] = 9293

          opt_parser = OptionParser.new do |opts|
            opts.banner = "Usage: litmus [options]"
            opts.separator ""

            opts.on("-b", "--binding=ip", String,
                    "Binds Litmus to the specified ip.", "Default: 0.0.0.0") { |v| options[:Host] = v }
            opts.on("-d", "--daemon", "Make server run as a Daemon.") { |d| options[:daemonize] = true }
            opts.on("-p", "--port=port", "Listen Port") { |p| options[:Port] = p }
            opts.on("-c", "--unicorn-config=config", "Unicorn Config") { |c| options[:unicorn_config] = c }

            opts.separator ""

            opts.on("-h", "--help", "Show this help message.") { puts opts; exit }
          end

          opt_parser.parse! args

          options
        end
      end

      def opt_parser
        Options.new
      end

      def start
        options = opt_parser.parse!(ARGV)
        unicorn_args = ['-c', options[:unicorn_config], '-l', "#{options[:Host]}:#{options[:Port]}"]
        unicorn_args << '-D' if options[:daemonize]
        Kernel.exec('unicorn', *unicorn_args)
      end

    end
  end
end
