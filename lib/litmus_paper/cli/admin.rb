module LitmusPaper
  module CLI
    class Admin
      def run(argv = ARGV)
        command = argv.shift
        send(command, argv)
      end

      def list(args)
        options = _default_options
        opt_parser = _extend_default_parser(options) do |opts|
          opts.banner = "Usage: litmusctl list [options]"
        end
        opt_parser.parse! args

        request = Net::HTTP::Get.new("/")
        _litmus_request(options[:host], options[:port], request)
      end

      def force(args)
        options = _default_options
        opt_parser = _extend_default_parser(options) do |opts|
          opts.banner = "Usage: litmusctl force <up|down> [service] [options]"
          opts.on("-d", "--delete", "Remove status file") do
            options[:delete] = true
          end
          opts.on("-r", "--reason=reason", String, "Reason for status file") do |reason|
            options[:reason] = reason
          end
        end

        opt_parser.parse! args
        direction, service = args

        if options[:delete]
          request = Net::HTTP::Delete.new("/force/#{direction}/#{service}")
        else
          if !options.has_key?(:reason)
            print "Reason? "
            options[:reason] = gets.chomp
          end
          request = Net::HTTP::Post.new("/force/#{direction}/#{service}")
          request.set_form_data('reason' => options[:reason])
        end

        _litmus_request(options[:host], options[:port], request)
      end

      def status(args)
        options = _default_options
        opt_parser = _extend_default_parser(options) do |opts|
          opts.banner = "Usage: litmusctl status <service> [options]"
        end

        opt_parser.parse! args
        service = args.shift

        _litmus_request(options[:host], options[:port], Net::HTTP::Get.new("/#{service}/status"))
      end

      def _default_options
        options = { :port => 9292, :host => 'localhost' }
      end

      def _extend_default_parser(options, &block)
        OptionParser.new do |opts|
          block.call(opts)

          opts.on("-p", "--port=port", Integer, "Port litmus is running on", "Default: 9292") do |port|
            options[:port] = port
          end
          opts.on("-h", "--host=ip", String, ":Host litmus is running on", "Default: localhost") do |host|
            options[:host] = host
          end
          opts.on("--help", "Show this help message.") { puts opts; exit }
        end
      end

      def _litmus_request(host, port, request)
        begin
          http = Net::HTTP.start(host, port)
          response = http.request(request)

          puts response.body
          case response
          when Net::HTTPSuccess then exit 0
          when Net::HTTPClientError then exit 2
          else exit 1
          end
        rescue Errno::ECONNREFUSED => e
          puts "Unable to connect to litmus on #{host}:#{port}: #{e.message}"
          exit 1
        end
      end
    end
  end
end
