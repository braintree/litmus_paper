require 'spec_helper'

describe LitmusPaper::Dependency::HaproxyBackends do
  describe "available?" do
    before(:each) do
      FileUtils.rm_rf("/tmp/stub-haproxy-stats")
      system "spec/support/haproxy_test_socket /tmp/stub-haproxy-stats &"
      sleep 1
    end

    it "is available if at least one backend is up" do
      pending "Broken on TravisCI 1.9.x; works locally" if ENV["TRAVIS_RUBY_VERSION"] =~ /\A1.9/
      haproxy = LitmusPaper::Dependency::HaproxyBackends.new("/tmp/stub-haproxy-stats", "yellow_cluster")
      haproxy.should be_available
    end

    it "returns 0 if no nodes are available" do
      pending "Broken on TravisCI 1.9.x; works locally" if ENV["TRAVIS_RUBY_VERSION"] =~ /\A1.9/
      haproxy = LitmusPaper::Dependency::HaproxyBackends.new("/tmp/stub-haproxy-stats", "orange_cluster")
      haproxy.should_not be_available
    end
  end
end

