require 'spec_helper'

describe LitmusPaper::StatusFile do
  describe "create" do
    it "creates a file" do
      status_file = LitmusPaper::StatusFile.new("foo", :up)
      status_file.create("for testing")

      expect(status_file.exists?).to eq(true)
    end

    it "writes the content" do
      status_file = LitmusPaper::StatusFile.new("foo", :up)
      status_file.create("for testing")

      expect(status_file.content).to match(/for testing/)
    end
  end

  describe "delete" do
    it "removes the file" do
      status_file = LitmusPaper::StatusFile.new("foo", :up)
      status_file.create("for testing")

      expect(status_file.exists?).to be_truthy

      status_file.delete

      expect(status_file.exists?).to be_falsey
    end
  end
end
