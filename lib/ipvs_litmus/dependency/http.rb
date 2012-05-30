module IPVSLitmus
  module Dependency
    class HTTP
      def initialize(uri, options = {})
        @uri = uri
        @expected_content = Regexp.new(options.fetch(:content, '.*'))
        @method = options.fetch(:method, 'GET')
      end

      def available?
        response = _make_request
        _successful_response?(response) && _body_matches?(response)
      rescue Exception
        false
      end

      def _make_request
        uri = URI.parse(@uri)
        request = Net::HTTP.const_get(@method.capitalize).new(uri.normalize.path)

        Net::HTTP.start(uri.host, uri.port) do |http|
          http.request(request)
        end
      end

      def _successful_response?(response)
        response.is_a? Net::HTTPSuccess
      end

      def _body_matches?(response)
        (response.body =~ @expected_content) ? true : false
      end

      def to_s
        "Dependency::HTTP(#{@uri})"
      end
    end
  end
end
