require 'spec_helper'
require 'tempfile'

describe LitmusPaper::Dependency::FileContents do
  describe "#available?" do
    it "is true when the file matches the regexp" do
      file_path = SpecHelper.create_temp_file("yes")

      check = LitmusPaper::Dependency::FileContents.new(file_path, /^yes$/)
      expect(check).to be_available
    end

    it "is false when the file does not match the regexp" do
      file_path = SpecHelper.create_temp_file("no")

      check = LitmusPaper::Dependency::FileContents.new(file_path, /^yes$/)
      expect(check).not_to be_available
    end

    it "is false when the script exceeds the timeout" do
      check = LitmusPaper::Dependency::FileContents.new("/dev/zero", /^timeout$/, :timeout => 1)
      expect(check).not_to be_available
    end

    it "logs exceptions and returns false" do
      check = LitmusPaper::Dependency::FileContents.new("/tmp/this_file_does_not_exist", /^foo$/)
      expect(LitmusPaper.logger).to receive(:info)
      expect(check).not_to be_available
    end
  end

  describe "to_s" do
    it "returns the command" do
      check = LitmusPaper::Dependency::FileContents.new("/path/to/file", /^a.regexp$/)
      expect(check.to_s).to eq("Dependency::FileContents(/path/to/file, /^a.regexp$/)")
    end
  end
end
