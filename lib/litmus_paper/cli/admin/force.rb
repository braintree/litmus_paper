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
          path = service ? "/#{service}/#{direction}" : "/#{direction}"

          if options[:delete]
            request = Net::HTTP::Delete.new(path)
          else
            if !options.has_key?(:reason)
              print "Reason? "
              options[:reason] = STDIN.gets.chomp
            end
            request = Net::HTTP::Post.new(path)
            request.set_form_data('reason' => options[:reason])
          end

          request
        end
      end
    end
  end
end
