require 'litmus_paper/agent_check_server'

module LitmusPaper
  class SinglePortAgentServer
    include AgentCheckServer

    VALID_NAME_REGEX = /\A([A-Za-z0-9_:.-]+)\z/.freeze
    MAX_BACKEND_NAME_LEN = 255.freeze

    def initialize(litmus_paper_config, daemonize, pid_file, port, workers)
      super(litmus_paper_config, daemonize, pid_file, workers)
      @services = LitmusPaper.services
      @control_sockets = [TCPServer.new(port)]
    end

    def service_for_connection(sock, addr)
      _, remote_port, _, remote_ip = sock.peeraddr

      msg = sock.gets.chomp

      if m = msg.match(VALID_NAME_REGEX)
        backend_name = m[0]
        LitmusPaper.logger.debug "Received request from #{remote_ip}:#{remote_port} for '#{backend_name}'"
        backend_name
      else
        LitmusPaper.logger.error "Received request from #{remote_ip}:#{remote_port}, but backend name could not be read."
        nil
      end
    end
  end
end
