require 'spec_helper'

describe LitmusPaper do
  describe 'configure' do
    it 'populates services from the config file' do
      LitmusPaper.configure(TEST_CONFIG)
      expect(LitmusPaper.services.has_key?('test')).to eq(true)
    end
  end

  describe "reload" do
    it "will reconfigure the services" do
      LitmusPaper.configure(TEST_CONFIG)
      replace_config_file(TEST_CONFIG, :with => TEST_RELOAD_CONFIG)
      LitmusPaper.services["bar"] = :service

      expect(LitmusPaper.services.has_key?('bar')).to eq(true)
      expect(LitmusPaper.services.has_key?('test')).to eq(true)

      LitmusPaper.reload

      expect(LitmusPaper.services.has_key?('bar')).to eq(false)
      expect(LitmusPaper.services.has_key?('test')).to eq(false)
      expect(LitmusPaper.services.has_key?('foo')).to eq(true)

      restore_config_file(TEST_CONFIG)
    end

    it "blows up when initial configuration is invalid" do
      bad_config_file = SpecHelper.create_temp_file(<<-END)
        service :old_service do |s|
          syntax error here
        end
      END
      expect do
        LitmusPaper.configure(bad_config_file)
      end.to raise_error(NameError)
    end

    it "keeps the old config if there are errors in the new config" do
      config_file = SpecHelper.create_temp_file(<<-END)
        service :old_service do |s|
          s.measure_health Metric::CPULoad, :weight => 100
        end
      END

      LitmusPaper.configure(config_file)
      expect(LitmusPaper.services.keys).to eq(["old_service"])

      File.open(config_file, "w") do |file|
        file.write(<<-END)
          service :old_service do |s|
            syntax error here
          end
        END
      end

      LitmusPaper.reload
      expect(LitmusPaper.services.keys).to eq(["old_service"])
    end
  end
end
