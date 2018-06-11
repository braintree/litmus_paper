require 'litmus_paper/haproxy_util'

module LitmusPaper
  module Metric
    class HaproxyBackendsHealth
      include LitmusPaper::HaproxyUtil

      def initialize(weight, domain_socket, cluster, options = {})
        @weight = weight
        @domain_socket = domain_socket
        @cluster = cluster
        @timeout = options.fetch(:timeout_seconds, 2)
      end

      def current_health
        servers = find_servers(@domain_socket, @timeout, @cluster)

        up_weight = servers
          .select { |server| server["status"] == "UP" }
          .inject(0) { |sum, server| sum + server["weight"].to_f }

        total_weight = servers
          .inject(0) { |sum, server| sum + server["weight"].to_f }

        ((up_weight / total_weight) * @weight).to_i
      end

      def to_s
        "Metric::HaproxyBackendsHealth(#{@weight}, #{@cluster})"
      end
    end
  end
end
