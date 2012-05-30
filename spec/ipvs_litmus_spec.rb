require 'spec_helper'

describe IPVSLitmus do
  describe 'configure' do
    it 'populates services from the config file' do
      IPVSLitmus.configure(TEST_CONFIG)
      IPVSLitmus.services.has_key?('test').should == true
    end
  end

  describe "reload" do
    it "will reconfigure the services" do
      IPVSLitmus.configure(TEST_CONFIG)
      IPVSLitmus.services["bar"] = :service

      IPVSLitmus.reload

      IPVSLitmus.services.has_key?('bar').should == false
      IPVSLitmus.services.has_key?('test').should == true
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
      IPVSLitmus.configure(old_config_file)
      IPVSLitmus.services.keys.should == ["old_service"]
      IPVSLitmus.configure(new_bad_config_file)
      IPVSLitmus.services.keys.should == ["old_service"]
    end
  end
end
