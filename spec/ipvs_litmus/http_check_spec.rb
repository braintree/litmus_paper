require 'spec_helper'

describe IPVSLitmus::HTTPCheck do
  describe "#success?" do
    it "is true when response is 200" do
      check = IPVSLitmus::HTTPCheck.new('http://httpstat.us/200')
      check.should be_success
    end

    it "is true when response is 200 and expected content matches" do
      check = IPVSLitmus::HTTPCheck.new('http://httpstat.us/200', :content => "200 OK")
      check.should be_success
    end

    it "is false when response is 200, but does not match content" do
      check = IPVSLitmus::HTTPCheck.new('http://httpstat.us/200', :content => "BAD STUFF")
      check.should be_success
    end

    it "is true when response is any 200 level response" do
      check = IPVSLitmus::HTTPCheck.new('http://httpstat.us/201')
      check.should be_success
      check = IPVSLitmus::HTTPCheck.new('http://httpstat.us/202')
      check.should be_success
    end

    it "is false when response is 500 " do
      check = IPVSLitmus::HTTPCheck.new('http://httpstat.us/500')
      check.should_not be_success
    end

    it "is false when the response is 404" do
      check = IPVSLitmus::HTTPCheck.new('http://httpstat.us/404')
      check.should_not be_success
    end
  end
end
