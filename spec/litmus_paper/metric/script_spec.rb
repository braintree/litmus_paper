require 'spec_helper'

describe LitmusPaper::Metric::Script do
  describe "#result" do
    it "is 1 when the script outputs 1" do
      check = LitmusPaper::Metric::Script.new("echo 1", 1)
      check.current_health.should == 1
    end

    it "is zero when the script exits 1" do
      check = LitmusPaper::Metric::Script.new("false", 1)
      check.current_health.should == 0
    end

    it "is zero when the script exceeds the timeout" do
      check = LitmusPaper::Metric::Script.new("sleep 10", 1, :timeout => 1)
      check.current_health.should == 0
    end

    it "kills the child process when script check exceeds timeout" do
      check = LitmusPaper::Metric::Script.new("sleep 50", 1, :timeout => 1)
      check.current_health.should == 0
      expect { Process.kill(0, check.script_pid) }.to raise_error(Errno::ESRCH)
    end

    it "can handle pipes" do
      check = LitmusPaper::Metric::Script.new("echo 'a' | tr a 1", 1)
      check.current_health.should == 1

      check = LitmusPaper::Metric::Script.new("echo 'a' | tr a 0", 0)
      check.current_health.should == 0
    end
  end

  describe "to_s" do
    it "returns the command" do
      check = LitmusPaper::Metric::Script.new("sleep 10", 1)
      check.to_s.should == "Metric::Script(sleep 10, 1)"
    end
  end
end
