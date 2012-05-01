require 'spec_helper'

describe IPVSLitmus do
  describe 'configure' do
    it 'populates services from the config file' do
      IPVSLitmus.configure(TEST_CONFIG)
      IPVSLitmus.services.has_key?('test').should == true
    end
  end
end
