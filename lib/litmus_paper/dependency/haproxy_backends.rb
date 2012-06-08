require 'csv'

module LitmusPaper
  module Dependency
    class HaproxyBackends

      module HaproxyStatReader
        def initialize(fiber)
          @fiber = fiber
          @stats = ""
        end

        def connection_completed
          send_data("show stat\n")
        end

        def receive_data(data)
          @stats << data
          @fiber.resume(@stats) if finished?
        end

        def finished?
          @stats =~ /\n\n\z/
        end
      end

      def initialize(domain_socket, cluster)
        @domain_socket = domain_socket
        @cluster = cluster
      end

      def available?
        stats = _parse_stats(_fetch_stats)
        servers = _servers_in(stats, @cluster)

        if not _any_up?(servers)
          LitmusPaper.logger.info("None of the servers (#{servers.map{ |s| s['svname'] }.join(',')}) are up")
          false
        else
          true
        end
      end

      def _any_up?(servers)
        available = servers.select { |s| s['status'] == "UP" }
        available.size > 0
      end

      def _servers_in(stats, cluster)
        stats.select do |line|
          line['# pxname'] == cluster && !["FRONTEND", "BACKEND"].include?(line["svname"])
        end
      end

      def _parse_stats(csv)
        stats = CSV.parse(_fetch_stats)
        headers = stats.shift
        stats.map { |stat| Hash[headers.zip(stat)] }
      end

      def _fetch_stats
        fiber = Fiber.current

        connection = EM.connect_unix_domain(@domain_socket, HaproxyStatReader, fiber)

        Fiber.yield
      end
    end
  end
end
