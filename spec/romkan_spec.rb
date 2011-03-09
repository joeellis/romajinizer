#coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Romkan" do
  it "should convert romaji to hiragana properly" do
    String.rom2hira("tsukue").should == "つくえ"
  end
end
