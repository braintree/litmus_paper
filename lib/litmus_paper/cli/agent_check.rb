module LitmusPaper
  module CLI
    class AgentCheck

      def parse_args(args)
        options = {}
        optparser = OptionParser.new do |opts|
          opts.on("-s", "--service SERVICE", "Service to check") do |s|
            options[:service] = s
          end
          opts.on("-c", "--config CONFIG", "Path to config file") do |c|
            options[:config] = c
          end
          opts.on("-h", "--help", "Help text") do |h|
            options[:help] = h
          end
        end

        begin
          optparser.parse! args
        rescue OptionParser::InvalidOption => e
          puts e
          puts optparser
          exit 1
        end

        if options[:help]
          puts optparser
          exit 0
        end

        if !options.has_key?(:service)
          puts "Error: `-s SERVICE` required"
          puts optparser
          exit 1
        end
        options
      end

      def output_service_status(service, stdout)
        output = []
        health = LitmusPaper.check_service(service)
        if health.nil?
          output << "failed#NOT_FOUND"
        else
          case health.direction
          when :up, :health
            output << "ready" # administrative state
            output << "up" # operational state
          when :down
            output << "drain" # administrative state
          when :none
            if health.ok?
              output << "ready" # administrative state
              output << "up" # operational state
            else
              output << "down" # operational state
            end
          end
          output << "#{health.value.to_s}%"
        end
        stdout.printf("%s\r\n", output.join("\t"))
      end

      def run(args)
        options = parse_args(args)
        LitmusPaper.configure(options[:config])
        output_service_status(options[:service], $stdout)
      end

    end
  end
end
