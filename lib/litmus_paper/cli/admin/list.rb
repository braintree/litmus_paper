module LitmusPaper
  module CLI
    class Admin
      class List < Command
        def self.description
          "List services"
        end

        def self.build_request(options, args)
          options.merge! _default_options
          opt_parser = _extend_default_parser(options) do |opts|
            opts.banner = "Usage: litmusctl list [options]"
          end
          opt_parser.parse! args

          Net::HTTP::Get.new("/")
        end
      end
    end
  end
end
