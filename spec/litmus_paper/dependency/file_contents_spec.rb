require 'spec_helper'
require 'tempfile'

describe LitmusPaper::Dependency::FileContents do
  describe "#available?" do
    it "is true when the file matches the regexp" do
      file_path = SpecHelper.create_temp_file("yes")

      check = LitmusPaper::Dependency::FileContents.new(file_path, /^yes$/)
      check.should be_available
    end

    it "is false when the file does not match the regexp" do
      file_path = SpecHelper.create_temp_file("no")

      check = LitmusPaper::Dependency::FileContents.new(file_path, /^yes$/)
      check.should_not be_available
    end

    it "is false when the script exceeds the timeout" do
      check = LitmusPaper::Dependency::FileContents.new("/dev/zero", /^timeout$/, :timeout => 1)
      check.should_not be_available
    end
  end

  describe "to_s" do
    it "returns the command" do
      check = LitmusPaper::Dependency::FileContents.new("/path/to/file", /^a.regexp$/)
      check.to_s.should == "Dependency::FileContents(/path/to/file, /^a.regexp$/)"
    end
  end
end
