require 'spec_helper'

describe LitmusPaper::ConfigurationFile do
  describe "evaluate" do
    it "configures a service" do
      config_file = LitmusPaper::ConfigurationFile.new(TEST_CONFIG)
      config = config_file.evaluate
      config.services.has_key?('test').should == true
    end

    it "configures the port to listen on" do
      config_file = LitmusPaper::ConfigurationFile.new(TEST_CONFIG)
      config = config_file.evaluate
      config.port.should == 9293
    end

    it "configures the data directory" do
      config_file = LitmusPaper::ConfigurationFile.new(TEST_CONFIG)
      config = config_file.evaluate
      config.data_directory.should == "/tmp/litmus_paper"
    end
  end

  describe "include_files" do
    it "configures a dir glob of services" do
      config_file = LitmusPaper::ConfigurationFile.new(TEST_D_CONFIG)
      config = config_file.evaluate
      config.services.has_key?('test').should == true
    end

    it "defaults configuration options" do
      config_file = LitmusPaper::ConfigurationFile.new(TEST_D_CONFIG)
      config = config_file.evaluate
      config.services.has_key?('test').should == true
      config.port.should == 9292
      config.data_directory.should == "/etc/litmus"
    end
  end
end
