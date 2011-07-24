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
  
  it "should convert kana to kana" do
    "こんばn".to_hiragana.should == "こんばん"
  end
  
  it "should be able to tell if a word contains anything else but kana" do
    "行きます".is_only_kana?.should == false
    "いきます".is_only_kana?.should == true
  end
  
  it "should be able to tell if a word contains kana" do
    "行きます".contains_kana?.should == true
    "abcdefg".contains_kana?.should == false
  end
end
