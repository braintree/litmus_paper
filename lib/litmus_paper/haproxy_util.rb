require 'csv'

module LitmusPaper
  module HaproxyUtil
    def find_servers(socket, timeout, cluster)
      stats = _get_stats(socket, timeout)
      stats.select do |line|
        line['# pxname'] == cluster && line['svname'] !~ /BACKEND|FRONTEND/
      end
    end

    def find_backend(socket, timeout, cluster)
      stats = _get_stats(socket, timeout)
      stats.detect do |line|
        line['# pxname'] == cluster && line['svname'] == 'BACKEND'
      end
    end

    def _get_stats(socket, timeout)
      _parse_stats(_fetch_stats(socket, timeout))
    end

    def _fetch_stats(socket, timeout)
      Timeout.timeout(timeout) do
        UNIXSocket.open(socket) do |socket|
          socket.send("show stat\n", 0)
          socket.read
        end
      end
    end

    def _parse_stats(csv)
      stats = CSV.parse(csv)
      headers = stats.shift
      stats.map { |stat| Hash[headers.zip(stat)] }
    end
  end
end

