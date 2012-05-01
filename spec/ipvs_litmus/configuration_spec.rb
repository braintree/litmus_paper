require 'spec_helper'

describe IPVSLitmus::Configuration do
  describe "evaluate" do
    it "configures a service" do
      config = IPVSLitmus::Configuration.new(TEST_CONFIG)
      services = config.evaluate
      services.has_key?('test').should == true
    end
  end
end
