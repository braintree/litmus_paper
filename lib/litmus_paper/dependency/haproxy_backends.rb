require 'csv'

module LitmusPaper
  module Dependency
    class HaproxyBackends < Base
      def initialize(domain_socket, cluster, options = {})
        @domain_socket = domain_socket
        @cluster = cluster
        @timeout = options.fetch(:timeout_seconds, 2)
      end

      def _available?
        stats = _parse_stats(_fetch_stats)
        backend = _find_backend(stats, @cluster)

        if backend['status'] != 'UP'
          LitmusPaper.logger.info("HAProxy available check failed, #{@cluster} backend is #{backend['status']}")
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

      def _find_backend(stats, cluster)
        stats.detect do |line|
          line['# pxname'] == cluster && line['svname'] == 'BACKEND'
        end
      end

      def _parse_stats(csv)
        stats = CSV.parse(csv)
        headers = stats.shift
        stats.map { |stat| Hash[headers.zip(stat)] }
      end

      def _fetch_stats
        Timeout.timeout(@timeout) do
          UNIXSocket.open(@domain_socket) do |socket|
            socket.send("show stat\n", 0)
            socket.read
          end
        end
      end
    end
  end
end
