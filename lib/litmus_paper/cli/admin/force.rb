module LitmusPaper
  module CLI
    class Admin
      class Force < Command
        def self.description
          "Force services up or down"
        end

        def self.build_request(options, args)
          options.merge! _default_options
          opt_parser = _extend_default_parser(options) do |opts|
            opts.banner = "Usage: litmusctl force [remove] <up|down|health N> [service] [options]"
            opts.on("-d", "--delete", "Remove status file") do
              options[:delete] = true
            end
            opts.on("-r", "--reason=reason", String, "Reason for status file") do |reason|
              options[:reason] = reason.gsub("\n", " ")
            end
          end

          opt_parser.parse! args
          if args[0] == "remove"
            options[:delete] = true
            args.shift
          end
          if args[0] == "health" && !options[:delete]
            direction, value, service = args
          else
            direction, service = args
          end
          path = service ? "/#{service}/#{direction}" : "/#{direction}"

          if options[:delete]
            request = Net::HTTP::Delete.new(path)
          else
            if !options.has_key?(:reason)
              print "Reason? "
              options[:reason] = STDIN.gets.chomp.gsub("\n", " ")
            end
            request = Net::HTTP::Post.new(path)
            params = {'reason' => options[:reason]}
            params.merge!({'health' => value}) if direction == 'health'
            request.set_form_data(params)
          end

          request
        end
      end
    end
  end
end
