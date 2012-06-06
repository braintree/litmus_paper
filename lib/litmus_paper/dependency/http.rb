module LitmusPaper
  module Dependency
    class HTTP
      VALID_RESPONSE_CODES = (200..399).freeze

      def initialize(uri, options = {})
        @uri = uri
        @expected_content = Regexp.new(options.fetch(:content, '.*'))
        @method = options.fetch(:method, 'get')
        @ca_file = options[:ca_file]
      end

      def available?
        response = _make_request
        success = _successful_response?(response)
        matches = _body_matches?(response)

        LitmusPaper.logger.info("Available check to #{@uri} failed with status #{response.response_header.status}") unless success
        LitmusPaper.logger.info("Available check to #{@uri} did not match #{@expected_content}") unless matches

        success && matches
      rescue Exception => e
        LitmusPaper.logger.info("Available check to #{@uri} failed with #{e.message}")
        false
      end

      def _make_request
        uri = URI.parse(@uri)
        request_options = {}
        request_options[:ssl] = {:verify_peer => true, :cert_chain_file => @ca_file} if uri.scheme == "https"

        EM::HttpRequest.new(@uri).send(@method.downcase, request_options)
      end

      def _successful_response?(response)
        VALID_RESPONSE_CODES.include? response.response_header.status
      end

      def _body_matches?(response)
        (response.response =~ @expected_content) ? true : false
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
