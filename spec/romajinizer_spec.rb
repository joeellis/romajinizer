#coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Romajinizer" do
  it "should convert romaji to hiragana properly" do
    "tsukue".to_hiragana.should == "つくえ"
    "kinnyoubi".to_hiragana.should == "きんようび"
    "kin'youbi".to_hiragana.should == "きんようび"
    "konnya".to_hiragana.should == "こんや"
    "konnnichi".to_hiragana.should == "こんにち"
    "kaetta".to_hiragana.should == "かえった"
  end
  
  it "should convert romaji to katakana properly" do
    "tsukue".to_katakana.should == "ツクエ"
  end
  
  it "should convert kana to romaji properly" do
    "つくえ".to_romaji.should == "tsukue"
    "きんようび".to_romaji.should == "kinyoubi"
    "こんや".to_romaji.should == "konya"
    "こんにち".to_romaji.should == "konnichi"
  end
end
