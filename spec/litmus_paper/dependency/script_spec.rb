require 'spec_helper'

describe LitmusPaper::Dependency::Script do
  describe "#available?" do
    it "is true when the script returns 0" do
      check = LitmusPaper::Dependency::Script.new("true")
      expect(check).to be_available
    end

    it "is false when the script returns 1" do
      check = LitmusPaper::Dependency::Script.new("false")
      expect(check).not_to be_available
    end

    it "is false when the script exceeds the timeout" do
      check = LitmusPaper::Dependency::Script.new("sleep 10", :timeout => 1)
      expect(check).not_to be_available
    end

    it "kills the child process when script check exceeds timeout" do
      check = LitmusPaper::Dependency::Script.new("sleep 50", :timeout => 1)
      expect(check).not_to be_available
      expect { Process.kill(0, check.script_pid) }.to raise_error(Errno::ESRCH)
    end

    it "can handle pipes" do
      check = LitmusPaper::Dependency::Script.new("ls | grep lib")
      expect(check).to be_available

      check = LitmusPaper::Dependency::Script.new("ls | grep missing")
      expect(check).not_to be_available
    end

    it "logs exceptions and returns false" do
      check = LitmusPaper::Dependency::Script.new("command_not_found")
      expect(LitmusPaper.logger).to receive(:info)
      expect(check).not_to be_available
    end
  end

  describe "to_s" do
    it "returns the command" do
      check = LitmusPaper::Dependency::Script.new("sleep 10")
      expect(check.to_s).to eq("Dependency::Script(sleep 10)")
    end
  end
end
