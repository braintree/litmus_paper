require 'spec_helper'

describe LitmusPaper do
  describe 'configure' do
    it 'populates services from the config file' do
      LitmusPaper.configure(TEST_CONFIG)
      LitmusPaper.services.has_key?('test').should == true
    end
  end

  describe "reload" do
    it "will reconfigure the services" do
      LitmusPaper.configure(TEST_CONFIG)
      LitmusPaper.services["bar"] = :service

      LitmusPaper.reload

      LitmusPaper.services.has_key?('bar').should == false
      LitmusPaper.services.has_key?('test').should == true
    end

    it "keeps the old config if there are errors in the new config" do
      old_config_file = SpecHelper.create_temp_file(<<-END)
        service :old_service do |s|
          s.measure_health Metric::CPULoad, :weight => 100
        end
      END
      new_bad_config_file = SpecHelper.create_temp_file(<<-END)
        service :old_service do |s|
          syntax error here
        end
      END
      LitmusPaper.configure(old_config_file)
      LitmusPaper.services.keys.should == ["old_service"]
      LitmusPaper.configure(new_bad_config_file)
      LitmusPaper.services.keys.should == ["old_service"]
    end
  end
end
