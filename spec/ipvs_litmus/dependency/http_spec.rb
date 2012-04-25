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
  end
end
