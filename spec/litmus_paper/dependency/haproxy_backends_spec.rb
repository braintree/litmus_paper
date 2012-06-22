require 'spec_helper'

describe LitmusPaper::Dependency::HaproxyBackends do
  describe "available?" do
    before(:each) do
      @file = File.expand_path("stub-haproxy-stats")
      FileUtils.rm_rf(@file)
      system "spec/support/haproxy_test_socket #{@file} &"
      sleep 1
    end

    it "is available if at least one backend is up" do
      haproxy = LitmusPaper::Dependency::HaproxyBackends.new(@file, "yellow_cluster")
      haproxy.should be_available
    end

    it "returns 0 if no nodes are available" do
      haproxy = LitmusPaper::Dependency::HaproxyBackends.new(@file, "orange_cluster")
      haproxy.should_not be_available
    end
  end
end

