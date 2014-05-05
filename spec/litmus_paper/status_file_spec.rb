require 'spec_helper'

describe LitmusPaper::StatusFile do
  describe "create" do
    it "creates a file" do
      status_file = LitmusPaper::StatusFile.new("foo", :up)
      status_file.create("for testing")

      status_file.exists?.should == true
    end

    it "writes the content" do
      status_file = LitmusPaper::StatusFile.new("foo", :up)
      status_file.create("for testing")

      status_file.content.should match(/for testing/)
    end
  end

  describe "delete" do
    it "removes the file" do
      status_file = LitmusPaper::StatusFile.new("foo", :up)
      status_file.create("for testing")

      status_file.exists?.should be_true

      status_file.delete

      status_file.exists?.should be_false
    end
  end
end
