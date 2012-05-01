module IPVSLitmus
  module CLI
    class Admin
      def run(argv = ARGV)
        command = argv.shift
        send(command, argv)
      end

      def status(args)
        service = args.shift

        response = Net::HTTP.get_response(URI.parse("http://localhost:9292/#{service}/status"))
        puts response.body

        case response
        when Net::HTTPSuccess then exit 0
        when Net::HTTPClientError then exit 2
        else exit 1
        end
      end
    end
  end
end
