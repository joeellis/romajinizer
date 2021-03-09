#coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Romajinizer" do
  it "should convert romaji to hiragana properly" do
    expect("tsukue".to_hiragana).to eq("つくえ")
    expect("kinnyoubi".to_hiragana).to eq("きんようび")
    expect("kin'youbi".to_hiragana).to eq("きんようび")
    expect("konnya".to_hiragana).to eq("こんや")
    expect("konnnichi".to_hiragana).to eq("こんにち")
    expect("kaetta".to_hiragana).to eq("かえった")
  end

  it "should convert romaji to katakana properly" do
    expect("tsukue".to_katakana).to eq("ツクエ")
  end

  it "should convert kana to romaji properly" do
    expect("つくえ".to_romaji).to eq("tsukue")
    expect("きんようび".to_romaji).to eq("kinyoubi")
    expect("こんや".to_romaji).to eq("konya")
    expect("こんにち".to_romaji).to eq("konnichi")
  end

  it "should convert kana to kana" do
    expect("こんばn".to_hiragana).to eq("こんばん")
  end

  it "should be able to tell if a word contains anything else but kana" do
    expect("行きます".is_only_kana?).to eq(false)
    expect("いきます".is_only_kana?).to eq(true)
  end

  it "should be able to tell if a word contains kana" do
    expect("行きます".contains_kana?).to eq(true)
    expect("abcdefg".contains_kana?).to eq(false)
  end

  it "should be able to tell if a character is a kana character" do
    expect("す".is_kana?).to eq(true)
  end

  it "should be able to tell if a character is a kanji character" do
    expect("行".is_kanji?).to eq(true)
    expect("あ".is_kanji?).to eq(false)
    expect("ア".is_kanji?).to eq(false)
    expect("〜".is_kanji?).to eq(false)
  end
end
