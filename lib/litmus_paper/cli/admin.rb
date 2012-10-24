module LitmusPaper
  module CLI
    class Admin
      def self.commands
        {
          "list" => LitmusPaper::CLI::Admin::List,
          "force" => LitmusPaper::CLI::Admin::Force,
          "status" => LitmusPaper::CLI::Admin::Status
        }
      end

      def run(argv = ARGV)
        command_name = argv.shift

        if command = Admin.commands[command_name]
          options = {}
          request = command.build_request(options, argv)
          LitmusPaper.configure(options[:litmus_config])
          _litmus_request('127.0.0.1', LitmusPaper.port, request)
        else
          _display_help
        end
      end

      def _display_help
        puts "Litmus Paper CLI v#{LitmusPaper::VERSION}\n\n"
        puts "Commands:\n"
        Admin.commands.keys.sort.each do |name|
          puts "  %-8s %s" % [name, Admin.commands[name].description]
        end
        puts "\nSee 'litmusctl <command> --help' for more information on a specific command"
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
