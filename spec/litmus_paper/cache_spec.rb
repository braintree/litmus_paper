require 'spec_helper'

describe LitmusPaper::Cache do
  before(:each) do
    @location = "/tmp/litmus_cache"
    @namespace = "test_cache"
    @ttl = -1
  end

  after(:each) do
    FileUtils.rm_rf(@location)
  end

  describe "initialize" do
    it "creates the directory structure" do
      File.exists?(@location).should be false
      LitmusPaper::Cache.new(@location, @namespace, @ttl)
      File.exists?(File.join(@location, @namespace)).should be true
    end
  end

  describe "get" do
    it "returns false if the key was not previously set" do
      cache = LitmusPaper::Cache.new(@location, @namespace, @ttl)
      cache.get("non-existant-key").should be_nil
    end

    context "when called with fresh entry" do
      it "returns the value set" do
        cache = LitmusPaper::Cache.new(@location, @namespace, 10)
        cache.set("key", "some value")
        cache.get("key").should == "some value"
      end
    end

    context "when called with expired entry" do
      it "returns nil" do
        cache = LitmusPaper::Cache.new(@location, @namespace, -1)
        cache.set("key", "some value")
        cache.get("key").should be_nil
      end
    end
  end

  describe "set" do
    context "when called with non-positive ttl" do
      it "does not store the value" do
        key = "key"
        cache = LitmusPaper::Cache.new(@location, @namespace, 0)
        cache.set(key, "some value")
        File.exists?(File.join(@location, @namespace, key)).should be false
      end
    end

    context "when called with positive ttl" do
      it "stores the value" do
        key = "key"
        cache = LitmusPaper::Cache.new(@location, @namespace, 1)
        cache.set(key, "some value")
        File.exists?(File.join(@location, @namespace, key)).should be true
      end
    end

    it "expires the entry after the ttl" do
      key = "key"
      ttl = 0.01
      cache = LitmusPaper::Cache.new(@location, @namespace, ttl)
      cache.set(key, "some value")
      cache.get(key).should == "some value"
      sleep ttl
      cache.get(key).should be_nil
    end

    it "it works when setting multiple entries" do
      key = "key"
      cache = LitmusPaper::Cache.new(@location, @namespace, 1)
      cache.set(key, "some value")
      cache.set(key, "other value")
      cache.get(key).should == "other value"
    end
  end
end
