require 'spec_helper'

describe LitmusPaper do
  describe 'configure' do
    it 'populates services from the config file' do
      LitmusPaper.config_file = TEST_CONFIG
      LitmusPaper.configure!
      LitmusPaper.services.has_key?('test').should == true
    end
  end

  describe "reload" do
    it "will reconfigure the services" do
      LitmusPaper.config_file = TEST_CONFIG
      LitmusPaper.configure!
      LitmusPaper.services["bar"] = :service

      LitmusPaper.reload

      LitmusPaper.services.has_key?('bar').should == false
      LitmusPaper.services.has_key?('test').should == true
    end

    it "keeps the old config if there are errors in the new config" do
      LitmusPaper.config_file = SpecHelper.create_temp_file(<<-END)
        service :old_service do |s|
          s.measure_health Metric::CPULoad, :weight => 100
        end
      END
      LitmusPaper.configure!
      LitmusPaper.config_file = SpecHelper.create_temp_file(<<-END)
        service :old_service do |s|
          syntax error here
        end
      END
      LitmusPaper.reload
    end
  end
end
