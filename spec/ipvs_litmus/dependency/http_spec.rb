require 'spec_helper'

describe IPVSLitmus::Dependency::HTTP do
  describe "#available?" do
    it "is true when response is 200" do
      check = IPVSLitmus::Dependency::HTTP.new('http://httpstat.us/200')
      check.should be_available
    end

    it "is true when response is 200 and expected content matches" do
      check = IPVSLitmus::Dependency::HTTP.new('http://httpstat.us/200', :content => "200 OK")
      check.should be_available
    end

    it "is false when response is 200, but does not match content" do
      check = IPVSLitmus::Dependency::HTTP.new('http://httpstat.us/200', :content => "BAD STUFF")
      check.should be_available
    end

    it "is true when response is any 200 level response" do
      check = IPVSLitmus::Dependency::HTTP.new('http://httpstat.us/201')
      check.should be_available
      check = IPVSLitmus::Dependency::HTTP.new('http://httpstat.us/202')
      check.should be_available
    end

    it "is false when response is 500 " do
      check = IPVSLitmus::Dependency::HTTP.new('http://httpstat.us/500')
      check.should_not be_available
    end

    it "is false when the response is 404" do
      check = IPVSLitmus::Dependency::HTTP.new('http://httpstat.us/404')
      check.should_not be_available
    end

    it "is false when the dependency is not available" do
      check = IPVSLitmus::Dependency::HTTP.new('http://127.0.0.1:7777')
      check.should_not be_available
    end
  end

  describe "to_s" do
    it "is the name of the class and the url" do
      check = IPVSLitmus::Dependency::HTTP.new('http://httpstat.us/500')
      check.to_s.should == "Dependency::HTTP(http://httpstat.us/500)"
    end
  end
end
