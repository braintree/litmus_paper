module LitmusPaper
  module CLI
    class Admin
      class Status < Command
        def self.description
          "Show service status"
        end

        def self.build_request(options, args)
          options.merge! _default_options
          opt_parser = _extend_default_parser(options) do |opts|
            opts.banner = "Usage: litmusctl status <service> [options]"
          end

          opt_parser.parse! args
          service = args.shift

          Net::HTTP::Get.new("/#{service}/status")
        end
      end
    end
  end
end
