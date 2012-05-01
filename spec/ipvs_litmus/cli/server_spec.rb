require 'spec_helper'
require 'ipvs_litmus/cli/server'

describe IPVSLitmus::CLI::Server do
  describe 'parse!' do
    it 'parses litmus config file options' do
      options = IPVSLitmus::CLI::Server::Options.new.parse!(['-c', 'foo.conf'])
      options[:litmus_config].should == 'foo.conf'
    end

    it 'parses the config dir options' do
      options = IPVSLitmus::CLI::Server::Options.new.parse!(['-D', '/tmp/foo'])
      options[:config_dir].should == '/tmp/foo'
    end
  end
end
