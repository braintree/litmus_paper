require 'csv'

module LitmusPaper
  module Dependency
    class HaproxyBackends
      def initialize(domain_socket, cluster, options = {})
        @domain_socket = domain_socket
        @cluster = cluster
        @timeout = options.fetch(:timeout_seconds, 2)
      end

      def available?
        stats = _parse_stats(_fetch_stats)
        backend = _find_backend(stats, @cluster)

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

      def average_weight
        stats = _parse_stats(_fetch_stats)
        backend = _find_backend(stats, @cluster)

        total_weight = backend['weight'].to_i
        total_servers = backend['act'].to_i

        return total_servers == 0 ? 0 : total_weight / total_servers
      rescue Timeout::Error
        LitmusPaper.logger.info("HAProxy average_weight check timed out for #{@cluster}")
        false
      rescue => e
        LitmusPaper.logger.info("HAProxy average_weight check failed for #{@cluster} with #{e.message}")
        false
      end

      def to_s
        "Dependency::HaproxyBackends(#{@domain_socket}, #{@cluster})"
      end

      def _find_backend(stats, cluster)
        stats.detect do |line|
          line['# pxname'] == cluster && line['type'] == '1'
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
