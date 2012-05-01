module IPVSLitmus
  module CLI
    class Admin
      def run(argv = ARGV)
        command = argv.shift
        send(command, argv)
      end

      def down(args)
        options = { :port => 9292, :host => 'localhost' }
        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: litmusctl down <service> [options]"

          opts.on("-d", "--delete", "Remove downfile") do
            options[:delete] = true
          end

          opts.on("-r", "--reason=reason", String, "Reason for downfile") do |reason|
            options[:reason] = reason
          end

          opts.on("-p", "--port=port", Integer, "Port litmus is running on", "Default: 9292") do |port|
            options[:port] = port
          end
          opts.on("-h", "--host=ip", String, ":Host litmus is running on", "Default: localhost") do |host|
            options[:host] = host
          end
          opts.on("--help", "Show this help message.") { puts opts; exit }
        end

        opt_parser.parse! args
        service = args.shift

        if options[:delete]
          request = Net::HTTP::Delete.new("/force/down/#{service}")
        else
          if !options.has_key?(:reason)
            print "Reason? "
            options[:reason] = gets.chomp
          end
          request = Net::HTTP::Post.new("/force/down/#{service}")
          request.set_form_data('reason' => options[:reason])
        end

        _litmus_request(options[:host], options[:port], request)
      end

      def up(args)
        options = { :port => 9292, :host => 'localhost' }
        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: litmusctl up <service> [options]"

          opts.on("-d", "--delete", "Remove downfile") do
            options[:delete] = true
          end

          opts.on("-r", "--reason=reason", String, "Reason for upfile") do |reason|
            options[:reason] = reason
          end

          opts.on("-p", "--port=port", Integer, "Port litmus is running on", "Default: 9292") do |port|
            options[:port] = port
          end
          opts.on("-h", "--host=ip", String, ":Host litmus is running on", "Default: localhost") do |host|
            options[:host] = host
          end
          opts.on("--help", "Show this help message.") { puts opts; exit }
        end

        opt_parser.parse! args
        service = args.shift

        if options[:delete]
          request = Net::HTTP::Delete.new("/force/up/#{service}")
        else
          if !options.has_key?(:reason)
            print "Reason? "
            options[:reason] = gets.chomp
          end
          request = Net::HTTP::Post.new("/force/up/#{service}")
          request.set_form_data('reason' => options[:reason])
        end

        _litmus_request(options[:host], options[:port], request)
      end

      def status(args)
        options = { :port => 9292, :host => 'localhost' }
        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: litmusctl status <service> [options]"
          opts.on("-p", "--port=port", Integer, "Port litmus is running on", "Default: 9292") do |port|
            options[:port] = port
          end
          opts.on("-h", "--host=ip", String, ":Host litmus is running on", "Default: localhost") do |host|
            options[:host] = host
          end
          opts.on("--help", "Show this help message.") { puts opts; exit }
        end

        opt_parser.parse! args
        service = args.shift

        _litmus_request(options[:host], options[:port], Net::HTTP::Get.new("/#{service}/status"))
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
