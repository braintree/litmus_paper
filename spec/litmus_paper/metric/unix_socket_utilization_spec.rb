require 'spec_helper'

describe LitmusPaper::Metric::UnixSocketUtilitization do
  describe "#current_health" do
    it "returns supplied weight when there is no queued request" do
      LitmusPaper::Metric::UnixSocketUtilitization.any_instance.stub(
        :_stats => OpenStruct.new({:queued => 0, :active => 10}),
      )
      health = LitmusPaper::Metric::UnixSocketUtilitization.new(
        100,
        '/var/run/foo.sock',
        10
      ).current_health
      health.should == 100
    end

    it "adjusts weight based on queued requests" do
      LitmusPaper::Metric::UnixSocketUtilitization.any_instance.stub(
        :_stats => OpenStruct.new({:queued => 7, :active => 10}),
      )
      health = LitmusPaper::Metric::UnixSocketUtilitization.new(
        100,
        '/var/run/foo.sock',
        10
      ).current_health
      health.to_i.should == 20
    end

    it "sets weight to 1 when queued requests is more than maxconn" do
      LitmusPaper::Metric::UnixSocketUtilitization.any_instance.stub(
        :_stats => OpenStruct.new({:queued => 11, :active => 10}),
      )
      health = LitmusPaper::Metric::UnixSocketUtilitization.new(
        100,
        '/var/run/foo.sock',
        10
      ).current_health
      health.should == 1
    end
  end
end
