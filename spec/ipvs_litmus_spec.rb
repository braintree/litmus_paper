require 'spec_helper'

describe IPVSLitmus do
  describe 'configure' do
    it 'populates services from the config file' do
      IPVSLitmus.configure((File.expand_path('support/test.config', File.dirname(__FILE__))))
      IPVSLitmus.services.has_key?('test').should == true
    end
  end
end
