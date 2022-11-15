# Preforking TCP server, mostly stolen from Jesse Storimer's Book Working with
# TCP Sockets

require 'socket'
require 'litmus_paper/agent_check_handler'

module LitmusPaper
  module AgentCheckServer
    CRLF = "\r\n".freeze

    attr_reader :control_sockets, :pid_file, :workers

    def initialize(litmus_paper_config, daemonize, pid_file, workers)
      LitmusPaper.configure(litmus_paper_config)
      @daemonize = daemonize
      @pid_file = pid_file
      @workers = workers

      trap(:INT) { exit }
      trap(:TERM) { exit }
    end

    def daemonize?
      !!@daemonize
    end


    def service_for_socket(socket)
      raise "Consumers must implemented service_for_socket(socket)"
    end

    def respond(sock, message)
      sock.write(message)
      sock.write(CRLF)
    end

    def write_pid(pid_file)
      File.open(pid_file, 'w') do |f|
        f.write(Process.pid)
      end
    end

    def run
      if daemonize?
        Process.daemon
      end
      write_pid(pid_file)
      child_pids = []

      workers.times do
        child_pids << spawn_child
      end

      kill_children = Proc.new { |signo|
        child_pids.each do |cpid|
          begin
            Process.kill(:INT, cpid)
          rescue Errno::ESRCH
          end
        end
        File.delete(pid_file) if File.exists?(pid_file)
        exit
      }

      trap(:INT, &kill_children)
      trap(:TERM, &kill_children)

      loop do
        pid = Process.wait
        LitmusPaper.logger.error("Process #{pid} quit unexpectedly")
        child_pids.delete(pid)
        child_pids << spawn_child
      end
    end

    def spawn_child
      fork do
        Socket.accept_loop(control_sockets) do |sock, addr|
          _, remote_port, _, remote_ip = sock.peeraddr(:numeric)

          begin
            service = service_for_socket(sock)
            respond(sock, AgentCheckHandler.handle(service))
            sock.close
          rescue Errno::ECONNRESET, Errno::EPIPE, Errno::ENOTCONN
            LitmusPaper.logger.debug "Received request from #{remote_ip}:#{remote_port}, but client hung up."
          end
        end
      end
    end
  end
end
