require 'litmus_paper/haproxy_util'

module LitmusPaper
  module Dependency
    class HaproxyBackends
      include LitmusPaper::HaproxyUtil

      def initialize(domain_socket, cluster, options = {})
        @domain_socket = domain_socket
        @cluster = cluster
        @timeout = options.fetch(:timeout_seconds, 2)
      end

      def available?
        backend = find_backend(@domain_socket, @timeout, @cluster)

        if backend['weight'].to_i == 0
          LitmusPaper.logger.info(
            "HAProxy available check failed for #{@cluster}, status: #{backend['status']}, weight: #{backend['weight']}"
          )
          return false
        end
        return true
      rescue Timeout::Error
        LitmusPaper.logger.info("HAProxy available check timed out for #{@cluster}")
        false
      rescue => e
        LitmusPaper.logger.info("HAProxy available check failed for #{@cluster} with #{e.message}")
        false
      end

      def to_s
        "Dependency::HaproxyBackends(#{@domain_socket}, #{@cluster})"
      end
    end
  end
end
