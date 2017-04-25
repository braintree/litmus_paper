require 'spec_helper'

describe LitmusPaper::ConfigurationFile do
  {"rb" => TEST_CONFIG, "yaml" => TEST_CONFIG_YAML}.each do |filetype, test_config|
    describe "evaluate #{filetype}" do
      it "configures a service" do
        config_file = LitmusPaper::ConfigurationFile.new(test_config)
        config = config_file.evaluate
        expect(config.services.has_key?('test')).to eq(true)
        expect(config.services.has_key?('passing_test')).to eq(true)
      end

      it "configures the port to listen on" do
        config_file = LitmusPaper::ConfigurationFile.new(test_config)
        config = config_file.evaluate
        expect(config.port).to eq(9293)
      end

      it "configures the data directory" do
        config_file = LitmusPaper::ConfigurationFile.new(test_config)
        config = config_file.evaluate
        expect(config.data_directory).to eq("/tmp/litmus_paper")
      end
    end
  end

  {"rb" => TEST_D_CONFIG, "yaml" => TEST_D_CONFIG_YAML}.each do |filetype, test_config|
    describe "evaluate #{filetype}" do
      describe "include_files" do
        it "configures a dir glob of services" do
          config_file = LitmusPaper::ConfigurationFile.new(test_config)
          config = config_file.evaluate
          expect(config.services.has_key?('test')).to eq(true)
          expect(config.services.has_key?('passing_test')).to eq(true)
        end

        it "defaults configuration options" do
          config_file = LitmusPaper::ConfigurationFile.new(test_config)
          config = config_file.evaluate
          expect(config.services.has_key?('test')).to eq(true)
          expect(config.port).to eq(9292)
          expect(config.data_directory).to eq("/etc/litmus")
        end
      end
    end
  end
end
