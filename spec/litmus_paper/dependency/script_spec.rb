require 'spec_helper'

describe LitmusPaper::Dependency::Script do
  describe "#available?" do
    it "is true when the script returns 0" do
      check = LitmusPaper::Dependency::Script.new("true")
      check.should be_available
    end

    it "is false when the script returns 1" do
      check = LitmusPaper::Dependency::Script.new("false")
      check.should_not be_available
    end

    it "is false when the script exceeds the timeout" do
      check = LitmusPaper::Dependency::Script.new("sleep 10", :timeout => 1)
      check.should_not be_available
    end
  end

  describe "to_s" do
    it "returns the command" do
      check = LitmusPaper::Dependency::Script.new("sleep 10")
      check.to_s.should == "Dependency::Script(sleep 10)"
    end
  end
end
