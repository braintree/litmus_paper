require 'spec_helper'

describe IPVSLitmus::Configuration do
  describe "evaluate" do
    it "configures a service" do
      config = IPVSLitmus::Configuration.new(File.expand_path('../support/test.config', File.dirname(__FILE__)))
      services = config.evaluate
      services.has_key?(:test).should == true
    end
  end
end
