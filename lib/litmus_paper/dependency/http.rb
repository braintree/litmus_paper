module LitmusPaper
  module Dependency
    class HTTP
      def initialize(uri, options = {})
        @uri = uri
        @expected_content = Regexp.new(options.fetch(:content, '.*'))
        @method = options.fetch(:method, 'GET')
        @ca_file = options[:ca_file]
        @timeout = options.fetch(:timeout_seconds, 5)
      end

      def available?
        response = _make_request
        success = _successful_response?(response)
        matches = _body_matches?(response)

        LitmusPaper.logger.info("Available check to #{@uri} failed with status #{response.code}") unless success
        LitmusPaper.logger.info("Available check to #{@uri} did not match #{@expected_content}") unless matches

        success && matches
      rescue Exception => e
        LitmusPaper.logger.info("Available check to #{@uri} failed with #{e.message}")
        false
      end

      def _make_request
        uri = URI.parse(@uri)
        request = Net::HTTP.const_get(@method.capitalize).new(uri.normalize.path)
        request.set_form_data({})

        connection = Net::HTTP.new(uri.host, uri.port)
        connection.open_timeout = @timeout
        connection.read_timeout = @timeout
        if uri.scheme == "https"
          connection.use_ssl = true
          connection.verify_mode = OpenSSL::SSL::VERIFY_PEER
          connection.ca_file = @ca_file unless @ca_file.nil?
          connection.verify_callback = proc { |preverify_ok, ssl_context| _verify_ssl_certificate(preverify_ok, ssl_context) }
        end

        connection.start do |http|
          http.request(request)
        end
      end

      def _successful_response?(response)
        response.is_a? Net::HTTPSuccess
      end

      def _body_matches?(response)
        (response.body =~ @expected_content) ? true : false
      end

      def _verify_ssl_certificate(preverify_ok, ssl_context)
        if preverify_ok != true || ssl_context.error != 0
          err_msg = "SSL Verification failed -- Preverify: #{preverify_ok}, Error: #{ssl_context.error_string} (#{ssl_context.error})"
          LitmusPaper.logger.info err_msg
          false
        end
        true
      end

      def to_s
        "Dependency::HTTP(#{@uri})"
      end
    end
  end
end
