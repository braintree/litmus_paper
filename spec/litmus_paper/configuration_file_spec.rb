require 'spec_helper'

describe LitmusPaper::ConfigurationFile do
  [TEST_CONFIG, TEST_CONFIG_YAML].each do |test_config|
    describe "evaluate #{File.extname(test_config)}" do
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

  [TEST_D_CONFIG, TEST_D_CONFIG_YAML].each do |test_config|
    describe "evaluate #{File.extname(test_config)}" do
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

  [TEST_DEPS_CONFIG, TEST_DEPS_CONFIG_YAML].each do |test_config|
    describe "configuring #{File.extname(test_config)} dependencies" do
      it "correctly sets a dependency with one arg" do
        config_file = LitmusPaper::ConfigurationFile.new(test_config)
        config = config_file.evaluate
        expect(config.services).to have_key("one_arg")
        dependency = config.services["one_arg"].instance_variable_get(:@dependencies).first
        expect(dependency.to_s).to eq("Dependency::HTTP(GET http://localhost/heartbeat)")
      end

      it "correctly sets a dependency with one arg and options" do
        config_file = LitmusPaper::ConfigurationFile.new(test_config)
        config = config_file.evaluate
        expect(config.services).to have_key("one_arg_with_options")
        dependency = config.services["one_arg_with_options"].instance_variable_get(:@dependencies).first
        expect(dependency.to_s).to eq("Dependency::HTTP(POST http://localhost/heartbeat)")
      end

      it "correctly sets a dependency with two args" do
        config_file = LitmusPaper::ConfigurationFile.new(test_config)
        config = config_file.evaluate
        expect(config.services).to have_key("two_args")
        dependency = config.services["two_args"].instance_variable_get(:@dependencies).first
        expect(dependency.to_s).to eq("Dependency::TCP(tcp://127.0.0.1:65534)")
      end

      it "correctly sets a dependency with two args and options" do
        config_file = LitmusPaper::ConfigurationFile.new(test_config)
        config = config_file.evaluate
        expect(config.services).to have_key("two_args_with_options")
        dependency = config.services["two_args_with_options"].instance_variable_get(:@dependencies).first
        expect(dependency.instance_variable_get(:@timeout)).to eq(1)
      end

      it "correctly sets a dependency with two args and options" do
        config_file = LitmusPaper::ConfigurationFile.new(test_config)
        config = config_file.evaluate
        expect(config.services).to have_key("two_args_with_options")
        dependency = config.services["two_args_with_options"].instance_variable_get(:@dependencies).first
        expect(dependency.instance_variable_get(:@timeout)).to eq(1)
      end

      it "correctly sets two dependencies of the same type" do
        config_file = LitmusPaper::ConfigurationFile.new(test_config)
        config = config_file.evaluate
        expect(config.services).to have_key("two_deps_of_same_type")
        dependencies = config.services["two_deps_of_same_type"].instance_variable_get(:@dependencies).map(&:to_s)
        expect(dependencies.to_s).to include("Dependency::HTTP(GET http://localhost/heartbeat1)")
        expect(dependencies.to_s).to include("Dependency::HTTP(GET http://localhost/heartbeat2)")
      end
    end
  end
end
