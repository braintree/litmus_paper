module LitmusPaper
  module CLI
    class Admin
      class Command
        def self._default_options
          options = { :litmus_config => "/etc/litmus.conf" }
        end

        def self._extend_default_parser(options, &block)
          OptionParser.new do |opts|
            block.call(opts)

            opts.on("-c", "--config=file", String, "Litmus configuration file", "Default: /etc/litmus.conf") do |config|
              options[:litmus_config] = config
            end
            opts.on("--help", "Show this help message.") { puts opts; exit }
          end
        end
      end
    end
  end
end
