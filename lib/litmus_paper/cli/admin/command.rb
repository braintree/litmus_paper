module LitmusPaper
  module CLI
    class Admin
      class Command
        def self._default_options
          options = { :port => 9292, :host => '127.0.0.1' }
        end

        def self._extend_default_parser(options, &block)
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
      end
    end
  end
end
