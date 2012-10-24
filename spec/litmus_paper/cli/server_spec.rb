require 'spec_helper'
require 'litmus_paper/cli/server'

describe LitmusPaper::CLI::Server do
  describe 'parse!' do
    it 'parses litmus config file options' do
      options = LitmusPaper::CLI::Server::Options.new.parse!(['-c', 'foo.conf'])
      options[:litmus_config].should == 'foo.conf'
    end
  end
end
