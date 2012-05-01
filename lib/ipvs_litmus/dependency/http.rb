module IPVSLitmus
  module Dependency
    class HTTP
      def initialize(uri, options = {})
        @uri = uri
        @expected_content = Regexp.new(options.fetch(:contnet, '.*'))
      end

      def available?
        begin
          response = Net::HTTP.get_response(URI.parse(@uri))
          _successful_response?(response) && _body_matches?(response)
        rescue Exception => e
          false
        end
      end

      def _successful_response?(response)
        response.is_a? Net::HTTPSuccess
      end

      def _body_matches?(response)
        response.body =~ @expected_content
      end
    end
  end
end
