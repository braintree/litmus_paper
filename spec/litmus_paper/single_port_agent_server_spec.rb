require 'spec_helper'
require 'litmus_paper/single_port_agent_server'

describe LitmusPaper::SinglePortAgentServer do
  pid = nil

  before :all do
    if ! Kernel.system("bundle exec litmus-agent-check -P 9191 -c spec/support/test.config -w 10 -D")
      fail('Unable to start server')
    end
    port_open = false
    while ! port_open do
      begin
        TCPSocket.new('127.0.0.1', 9191)
      rescue StandardError => e
        sleep 0.1
        next
      end
      port_open = true
    end
  end

  after :all do
    Process.kill(:TERM, File.read('/tmp/litmus-agent-check.pid').to_i)
  end

  describe "The agent-check text protocol" do
    it "returns the health from a passing test" do
      TCPSocket.open('127.0.0.1', 9191) do |s|
        s.puts "passing_test"
        s.gets.should match(/ready\tup\t\d+%\r\n/)
      end
    end
    it "returns the health from a failing test" do
      TCPSocket.open('127.0.0.1', 9191) do |s|
        s.puts "test"
        s.gets.should match(/down\t0%\r\n/)
      end
    end
    it "returns a failure for a non-existent service" do
      TCPSocket.open('127.0.0.1', 9191) do |s|
        s.puts "foo"
        s.gets.should match(/failed#NOT_FOUND\r\n/)
      end
    end
    it "returns a failure for a bad message" do
      TCPSocket.open('127.0.0.1', 9191) do |s|
        s.puts "\n"
        s.gets.should match(/failed#BAD_INPUT\r\n/)
      end
    end
  end

  describe "server" do
    it "has the configured number of children running" do
      pid = File.read('/tmp/litmus-agent-check.pid').to_i
      children = `ps --no-headers --ppid #{pid}|wc -l`
      children.strip.to_i == 10
    end
  end

  describe "server" do
    it "if a child dies you get a new one" do
      pid = File.read('/tmp/litmus-agent-check.pid').to_i
      Kernel.system("kill -9 $(ps --no-headers --ppid #{pid} -o pid=|tail -1)")
      sleep 0.5
      children = `ps --no-headers --ppid #{pid}|wc -l`
      children.strip.to_i == 10
    end
  end
end
