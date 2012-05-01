module IPVSLitmus
  module CLI
    class Admin
      def run(argv = ARGV)
        command = argv.shift
        send(command, argv)
      end

      def status(args)
        options = { :port => 9292, :host => 'localhost' }
        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: litmusctl status <service> [options]"
          opts.on("-p", "--port=port", Integer,
                  "Port litmus is running on", "Default: 9292") { |v| options[:port] = v }
          opts.on("-h", "--host=ip", String,
                  ":Host litmus is running on", "Default: localhost") { |v| options[:host] = v }

          opts.separator ""

          opts.on("--help", "Show this help message.") { puts opts; exit }
        end

        opt_parser.parse! args
        service = args.shift

        begin
          response = Net::HTTP.get_response(URI.parse("http://#{options[:host]}:#{options[:port]}/#{service}/status"))
          puts response.body
          case response
          when Net::HTTPSuccess then exit 0
          when Net::HTTPClientError then exit 2
          else exit 1
          end
        rescue Errno::ECONNREFUSED => e
          puts "Unable to connect to litmus on #{options[:host]}:#{options[:port]}: #{e.message}"
          exit 1
        end
      end
    end
  end
end
