require 'litmus_paper/agent_check_server'

module LitmusPaper
  class MultiPortAgentServer
    include AgentCheckServer

    def initialize(litmus_paper_config, daemonize, pid_file, services, workers)
      super(litmus_paper_config, daemonize, pid_file, workers)
      @services = services
      @control_sockets = @services.keys.map do |port|
        TCPServer.new(port)
      end
    end

    def service_for_socket(socket)
      _, remote_port, _, remote_ip = socket.peeraddr
      LitmusPaper.logger.debug "Received request from #{remote_ip}:#{remote_port}"
      services[socket.local_address.ip_port]
    end
  end
end
