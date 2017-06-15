# Preforking TCP server, mostly stolen from Jesse Storimer's Book Working with
# TCP Sockets

require 'socket'
require 'litmus_paper/agent_check_handler'

module LitmusPaper
  class AgentCheckServer
    CRLF = "\r\n"

    def initialize(litmus_paper_config, services, workers, pid_file, daemonize)
      LitmusPaper.configure(litmus_paper_config)
      @services = services
      @workers = workers
      @pid_file = pid_file
      @daemonize = daemonize
      @control_sockets = @services.keys.map do |port|
        TCPServer.new(port)
      end
      trap(:INT) { exit }
      trap(:TERM) { exit }
    end

    # Stolen pattern from ruby Socket, modified to return the service based on
    # the accepting port
    def accept_loop(*sockets)
      sockets.flatten!(1)
      if sockets.empty?
        raise ArgumentError, "no sockets"
      end
      loop {
        readable, _, _ = IO.select(sockets)
        readable.each { |r|
          begin
            sock, addr = r.accept_nonblock
            service = @services[r.local_address.ip_port]
          rescue IO::WaitReadable
            next
          end
          yield sock, service
        }
      }
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
      if @daemonize
        Process.daemon
      end
      write_pid(@pid_file)
      child_pids = []

      @workers.times do
        child_pids << spawn_child
      end

      kill_children = Proc.new { |signo|
        child_pids.each do |cpid|
          begin
            Process.kill(:INT, cpid)
          rescue Errno::ESRCH
          end
        end
        File.delete(@pid_file) if File.exists?(@pid_file)
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
        accept_loop(@control_sockets) do |sock, service|
          respond(sock, AgentCheckHandler.handle(service))
          sock.close
        end
      end
    end
  end
end
