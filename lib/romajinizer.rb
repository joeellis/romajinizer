# coding: utf-8

#
# kana2rom.rb
# A Ruby module for converting between hiragana, katakana and romaji.
#
# ---------------------------------------------------------------------------------
# K.Kodama 2002.06
# This script is distributed freely in the sense of GNU General Public License.
# http://www.gnu.org/licenses/gpl.html
#
# ---------------------------------------------------------------------------------
# Paul Chapman (paul [a../t] longweekendmobile 2010-04-01)
# Repaired script to work with modern Ruby versions (1.86+), added comments, 
# made it support gaijin friendly transliterations!
# ---------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------
# Joe Ellis (joe at squarefour.net 2011-03-09)
# Added a few more edge cases ('n romaji support), 
# Started gemifications so it can easily be used in any project 
# Added normalization for double nn so that こんばn will still be converted to こんばん properly
# ---------------------------------------------------------------------------------

# USAGE
#
# Include kana2rom
#
#  kana2rom(str)     かな --> ロ－マ字 変換    /   hira/katakana ->> romaji conv
#  rom2kata(str)     ロ－マ字 --> 片仮名 変換   /   romaji --> katakana　conv
#  rom2hira(str)     ロ－マ字 --> 平仮名 変換   /   romaji　--> hiragana conv
#  hira2kata(str)    平仮名 --> 片仮名 変換    /   hiragana --> katakana conv
#  kata2hira(str)    片仮名 --> 平仮名 変換    /   katakana ->> hiragana conv
#  kana2kana(str)   attempts either to either, returns unique strings only
#
# ---------------------------------------------------------------------------------

module Kana2rom

  HiraganaCharacters = [
    ' ', '　', '々', '～', 'っ', 'ょ', 'ゃ', 'ゅ', 'あ', 'い', 'う', 
    'え', 'お', 'か', 'き', 'く', 'け', 'こ', 'さ', 'し', 'す', 'せ', 
    'そ', 'た', 'ち', 'つ', 'て', 'と', 'な', 'に', 'ぬ', 'ね', 'の', 
    'は', 'ひ', 'ふ', 'へ', 'ほ', 'ま', 'み', 'む', 'め', 'も', 'や', 
    'ゆ', 'よ', 'ら', 'り', 'る', 'れ', 'ろ', 'わ', 'ゐ', 'ゑ', 'を', 
    'ん', 'が', 'ぎ', 'ぐ', 'げ', 'ご', 'ざ', 'じ', 'ず', 'ぜ', 'ぞ', 
    'だ', 'ぢ', 'づ', 'で', 'ど', 'ば', 'び', 'ぶ', 'べ', 'ぼ', 'ぱ', 
    'ぴ', 'ぷ', 'ぺ', 'ぽ', 'ヶ'
  ]

  KatakanaCharacters = [
    'ョ', 'ャ', 'ュ', 'ア', 'イ', 'ウ', 'エ', 'オ', 'カ', 'キ', 'ク', 
    'ケ', 'コ', 'サ', 'シ', 'ス', 'セ', 'ソ', 'タ', 'チ', 'ツ', 'テ', 
    'ト', 'ナ', 'ニ', 'ヌ', 'ネ', 'ノ', 'ハ', 'ヒ', 'フ', 'ヘ', 'ホ', 
    'マ', 'ミ', 'ム', 'メ', 'モ', 'ヤ', 'ユ', 'ヨ', 'ラ', 'リ', 'ル', 
    'レ', 'ロ', 'ワ', 'ゐ', 'ゑ', 'ヲ', 'ン', 'ガ', 'ギ', 'グ', 'ゲ', 
    'ゴ', 'ザ', 'ジ', 'ズ', 'ゼ', 'ゾ', 'ダ', 'ヅ', 'ヂ', 'ズ', 'デ', 
    'ド', 'バ', 'ビ', 'ブ', 'ベ', 'ボ', 'パ', 'ピ', 'プ', 'ペ', 'ポ'
  ] 


  Kana2romH={
    "ア"=>"a", "イ"=>"i", "ウ"=>"u", "エ"=>"e","オ"=>"o",
    "あ"=>"a", "い"=>"i", "う"=>"u", "え"=>"e","お"=>"o",
    "カ"=>"ka", "キ"=>"ki", "ク"=>"ku", "ケ"=>"ke", "コ"=>"ko",
    "か"=>"ka", "き"=>"ki", "く"=>"ku", "け"=>"ke", "こ"=>"ko",
    "ガ"=>"ga", "ギ"=>"gi", "グ"=>"gu", "ゲ"=>"ge", "ゴ"=>"go",
    "が"=>"ga", "ぎ"=>"gi", "ぐ"=>"gu", "げ"=>"ge", "ご"=>"go",
    "サ"=>"sa", "シ"=>"si", "ス"=>"su", "セ"=>"se", "ソ"=>"so",
    "さ"=>"sa", "し"=>"shi","す"=>"su", "せ"=>"se", "そ"=>"so",
    "ザ"=>"za", "ジ"=>"ji", "ズ"=>"zu", "ゼ"=>"ze", "ゾ"=>"zo",
    "ざ"=>"za", "じ"=>"ji", "ず"=>"zu", "ぜ"=>"ze", "ぞ"=>"zo",
    "タ"=>"ta", "チ"=>"chi","ツ"=>"tsu","テ"=>"te", "ト"=>"to",
    "た"=>"ta", "ち"=>"chi","つ"=>"tsu","て"=>"te", "と"=>"to",
    "ダ"=>"da", "ヂ"=>"dji","ヅ"=>"dzu","デ"=>"de", "ド"=>"do",
    "だ"=>"da", "ぢ"=>"dji","づ"=>"dzu","で"=>"de", "ど"=>"do",
    "ナ"=>"na", "ニ"=>"ni", "ヌ"=>"nu", "ネ"=>"ne", "ノ"=>"no",
    "な"=>"na", "に"=>"ni", "ぬ"=>"nu", "ね"=>"ne", "の"=>"no",
    "ハ"=>"ha", "ヒ"=>"hi", "フ"=>"fu", "ヘ"=>"he", "ホ"=>"ho",
    "は"=>"ha", "ひ"=>"hi", "ふ"=>"fu", "へ"=>"he", "ほ"=>"ho",
    "バ"=>"ba", "ビ"=>"bi", "ブ"=>"bu", "ベ"=>"be", "ボ"=>"bo",
    "ば"=>"ba", "び"=>"bi", "ぶ"=>"bu", "べ"=>"be", "ぼ"=>"bo",
    "パ"=>"pa", "ピ"=>"pi", "プ"=>"pu", "ペ"=>"pe", "ポ"=>"po",
    "ぱ"=>"pa", "ぴ"=>"pi", "ぷ"=>"pu", "ぺ"=>"pe", "ぽ"=>"po",
    "マ"=>"ma", "ミ"=>"mi", "ム"=>"mu", "メ"=>"me", "モ"=>"mo",
    "ま"=>"ma", "み"=>"mi", "む"=>"mu", "め"=>"me", "も"=>"mo",
    "ヤ"=>"ya", "ユ"=>"yu", "ヨ"=>"yo",
    "や"=>"ya", "ゆ"=>"yu", "よ"=>"yo",
    "ラ"=>"ra", "リ"=>"ri", "ル"=>"ru","レ"=>"re","ロ"=>"ro",
    "ら"=>"ra", "り"=>"ri", "る"=>"ru","れ"=>"re","ろ"=>"ro",
    "ワ"=>"wa", "ヰ"=>"wi", "ヱ"=>"we", "ヲ"=>"wo", "ン"=>"nn",
    "わ"=>"wa", "ゐ"=>"wi", "ゑ"=>"we", "を"=>"wo", "ん"=>"nn",
    "ァ"=>"xa", "ィ"=>"xi", "ゥ"=>"xu", "ェ"=>"xe", "ォ"=>"xo",
    "ぁ"=>"xa", "ぃ"=>"xi", "ぅ"=>"xu", "ぇ"=>"xe", "ぉ"=>"xo",
    "ッ"=>"xtsu","ャ"=>"xya", "ュ"=>"xyu", "ョ"=>"xyo",
    "っ"=>"xtsu","ゃ"=>"xya", "ゅ"=>"xyu", "ょ"=>"xyo",
    "ヴ"=>"vu", "ヵ"=>"xka","ヶ"=>"ga","ヮ"=>"xwa",
    "ゎ"=>"xwa",
    "ー"=>"-", "−"=>"-", "゛"=>'"', "゜"=>"'", "、"=>",", "。"=>".",
    "："=>":", "　" => " ", "＠" => "@", "（" => "(", "）" => ")",
    " " => " "
  }

  Kana2romH2={
    "てぃ" => "ti", "でぃ" => "di"
  }
  # 1 character romaji patterns
  Rom2KataH1={
    "a"=>"ア", "i"=>"イ", "u"=>"ウ", "e"=>"エ", "o"=>"オ", "-"=>"ー"
  }

  # 2 character romaji patterns
  Rom2KataH2={
    "xa"=>"ァ", "xi"=>"ィ", "xu"=>"ゥ", "xe"=>"ェ", "xo"=>"ォ",
    "ka"=>"カ", "ki"=>"キ", "ku"=>"ク", "ke"=>"ケ", "ko"=>"コ",
    "ca"=>"カ", "cu"=>"ク", "co"=>"コ",
    "ga"=>"ガ", "gi"=>"ギ", "gu"=>"グ", "ge"=>"ゲ", "go"=>"ゴ", 
    "sa"=>"サ", "si"=>"シ", "su"=>"ス", "se"=>"セ", "so"=>"ソ", 
    "za"=>"ザ", "zi"=>"ジ", "zu"=>"ズ", "ze"=>"ゼ", "zo"=>"ゾ",
    "ja"=>"ジャ","ji"=>"ジ", "ju"=>"ジュ","je"=>"ジェ","jo"=>"ジョ", 
    "ta"=>"タ", "ti"=>"チ", "tsu"=>"ツ", "te"=>"テ", "to"=>"ト", 
    "da"=>"ダ", "di"=>"ヂ", "du"=>"ヅ", "de"=>"デ", "do"=>"ド", 
    "na"=>"ナ", "ni"=>"ニ", "nu"=>"ヌ", "ne"=>"ネ", "no"=>"ノ", 
    "ha"=>"ハ", "hi"=>"ヒ", "hu"=>"フ", "he"=>"ヘ", "ho"=>"ホ", 
    "ba"=>"バ", "bi"=>"ビ", "bu"=>"ブ", "be"=>"ベ", "bo"=>"ボ", 
    "pa"=>"パ", "pi"=>"ピ", "pu"=>"プ", "pe"=>"ペ", "po"=>"ポ", 
    "va"=>"ヴァ","vi"=>"ヴィ","vu"=>"ヴ", "ve"=>"ヴェ","vo"=>"ヴォ", 
    "fa"=>"ファ","fi"=>"フィ","fu"=>"フ", "fe"=>"フェ","fo"=>"フォ", 
    "ma"=>"マ", "mi"=>"ミ", "mu"=>"ム", "me"=>"メ", "mo"=>"モ", 
    "ya"=>"ヤ", "yi"=>"イ", "yu"=>"ユ", "ye"=>"イェ", "yo"=>"ヨ", 
    "ra"=>"ラ", "ri"=>"リ", "ru"=>"ル", "re"=>"レ", "ro"=>"ロ", 
    "la"=>"ラ", "li"=>"リ", "lu"=>"ル", "le"=>"レ", "lo"=>"ロ", 
    "wa"=>"ワ", "wi"=>"ヰ", "wu"=>"ウ", "we"=>"ヱ", "wo"=>"ヲ", 
    "nn"=>"ン"
  }

  # 3 character romaji patterns
  Rom2KataH3={
    "tsu"=>"ツ",
    "xka"=>"ヵ", "xke"=>"ヶ",
    "xwa"=>"ヮ", "xtsu"=>"ッ",   "xya"=>"ャ",  "xyu"=>"ュ",  "xyo"=>"ョ",
    "kya"=>"キャ", "kyi"=>"キィ", "kyu"=>"キュ", "kye"=>"キェ", "kyo"=>"キョ", 
    "gya"=>"ギャ", "gyi"=>"ギィ", "gyu"=>"ギュ", "gye"=>"ギェ", "gyo"=>"ギョ", 
    "sya"=>"シャ", "syi"=>"シィ", "syu"=>"シュ", "sye"=>"シェ", "syo"=>"ショ", 
    "sha"=>"シャ", "shi"=>"シ",  "shu"=>"シュ", "she"=>"シェ", "sho"=>"ショ", 
    "zya"=>"ジャ", "zyi"=>"ジィ", "zyu"=>"ジュ", "zye"=>"ジェ", "zyo"=>"ジョ", 
    "jya"=>"ジャ", "jyi"=>"ジィ", "jyu"=>"ジュ", "jye"=>"ジェ", "jyo"=>"ジョ",
    "tya"=>"チャ", "tyi"=>"チィ", "tyu"=>"チュ", "tye"=>"チェ", "tyo"=>"チョ", 
    "cya"=>"チャ", "cyi"=>"チィ", "cyu"=>"チュ", "cye"=>"チェ", "cyo"=>"チョ", 
    "cha"=>"チャ", "chi"=>"チ",  "chu"=>"チュ", "che"=>"チェ", "cho"=>"チョ", 
    "tha"=>"テャ", "thi"=>"ティ", "thu"=>"テュ", "the"=>"テェ", "tho"=>"テョ", 
    "dya"=>"ヂャ", "dyi"=>"ヂィ", "dyu"=>"ヂュ", "dye"=>"ヂェ", "dyo"=>"ヂョ", 
    "dha"=>"デャ", "dhi"=>"ディ", "dhu"=>"デュ", "dhe"=>"デェ", "dho"=>"デョ", 
    "nya"=>"ニャ", "nyi"=>"ニィ", "nyu"=>"ニュ", "nye"=>"ニェ", "nyo"=>"ニョ",
    "hya"=>"ヒャ", "hyi"=>"ヒィ", "hyu"=>"ヒュ", "hye"=>"ヒェ", "hyo"=>"ヒョ", 
    "bya"=>"ビャ", "byi"=>"ビィ", "byu"=>"ビュ", "bye"=>"ビェ", "byo"=>"ビョ", 
    "pya"=>"ピャ", "pyi"=>"ピィ", "pyu"=>"ピュ", "pye"=>"ピェ", "pyo"=>"ピョ", 
    "mya"=>"ミャ", "myi"=>"ミィ", "myu"=>"ミュ", "mye"=>"ミェ", "myo"=>"ミョ", 
    "rya"=>"リャ", "ryi"=>"リィ", "ryu"=>"リュ", "rye"=>"リェ", "ryo"=>"リョ",
    "lya"=>"リャ", "lyi"=>"リィ", "lyu"=>"リュ", "lye"=>"リェ", "lyo"=>"リョ"
  }

  Kata2hiraH={
    "ア"=>"あ", "イ"=>"い", "ウ"=>"う", "エ"=>"え", "オ"=>"お",
    "カ"=>"か", "キ"=>"き", "ク"=>"く", "ケ"=>"け", "コ"=>"こ",
    "ガ"=>"が", "ギ"=>"ぎ", "グ"=>"ぐ", "ゲ"=>"げ", "ゴ"=>"ご",
    "サ"=>"さ", "シ"=>"し", "ス"=>"す", "セ"=>"せ", "ソ"=>"そ",
    "ザ"=>"ざ", "ジ"=>"じ", "ズ"=>"ず", "ゼ"=>"ぜ", "ゾ"=>"ぞ",
    "タ"=>"た", "チ"=>"ち", "ツ"=>"つ", "テ"=>"て", "ト"=>"と",
    "ダ"=>"だ", "ヂ"=>"ぢ", "ヅ"=>"づ", "デ"=>"で", "ド"=>"ど",
    "ナ"=>"な", "ニ"=>"に", "ヌ"=>"ぬ", "ネ"=>"ね", "ノ"=>"の",
    "ハ"=>"は", "ヒ"=>"ひ", "フ"=>"ふ", "ヘ"=>"へ", "ホ"=>"ほ",
    "バ"=>"ば", "ビ"=>"び", "ブ"=>"ぶ", "ベ"=>"べ", "ボ"=>"ぼ",
    "パ"=>"ぱ", "ピ"=>"ぴ", "プ"=>"ぷ", "ペ"=>"ぺ", "ポ"=>"ぽ",
    "マ"=>"ま", "ミ"=>"み", "ム"=>"む", "メ"=>"め", "モ"=>"も",
    "ヤ"=>"や", "ユ"=>"ゆ", "ヨ"=>"よ",
    "ラ"=>"ら", "リ"=>"り", "ル"=>"る", "レ"=>"れ", "ロ"=>"ろ",
    "ワ"=>"わ", "ヰ"=>"ゐ", "ヱ"=>"ゑ", "ヲ"=>"を", "ン"=>"ん",
    "ァ"=>"ぁ", "ィ"=>"ぃ", "ゥ"=>"ぅ", "ェ"=>"ぇ", "ォ"=>"ぉ",
    "ッ"=>"っ", "ャ"=>"ゃ", "ュ"=>"ゅ", "ョ"=>"ょ",
    "ヴ"=>"う゛", "ヵ"=>"か", "ヶ"=>"が", "ヮ"=>"ゎ"
  }

  Hira2kataH={}; Kata2hiraH.each_pair{|k,v| Hira2kataH[v]=k}; Hira2kataH["か"]="カ"; Hira2kataH["が"]="ガ"

  def kana2rom
    s=""
    self.each_char do |c|
      if (Kana2romH.key?(c))
        s += Kana2romH[c]
      else 
        s += c
      end
    end

    s=s.gsub(/(k)([aiueo])(")/,'g\2').gsub(/(s)([aiueo])(")/,'z\2').gsub(/(t)([aiueo])(")/,'d\2')
    s=s.gsub(/(h)([aiueo])(")/,'b\2').gsub(/([fh])([aiueo])(')/,'p\2').gsub(/u"/,'vu') # [半]濁点゛゜
    #---------------------------------------------------------
    s=s.gsub(/\s(xtsu)?\s/,'xtsu')                            # Remove spaces before/after hanging 'っ'
    #---------------------------------------------------------
    sw=s;
    while nil!=sw.gsub!(/(xtsu)([ckgszjtdhfbpmyrwnv])/,'\2\2') do; s=sw; end # ッカ-->xtsuka-->kka
    #---------------------------------------------------------
    # Compound Phoneme Pattern Rollbacks
    # NB: Uses regex backrefs like "\1y\3" where \1 = 1st capture grp, y='y' and \3 = 3rd capture grp
    #---------------------------------------------------------
    s=s.gsub(/( +x)(.*)/,'x\2')                               # Avoid hanging chisaii moji due to leading spaces
    s=s.gsub(/(ch)(ixy)([aueo])/,'\1\3')                      # チョ-->chixyo-->cho
    s=s.gsub(/([kgszjtdnhfbpmr])(ixy)([auo])/,'\1y\3')        # キャ-->kixya-->kya
    s=s.gsub(/([kgszjtdnhfbpmr])(ix)([ie])/,'\1y\3')          # キィ-->kixi-->kyi
    #---------------------------------------------------------
    s=s.gsub(/(sh)(y)([aueo])/,'\1\3')                        # シュ-->shyu-->shu
    s=s.gsub(/(j)(y)([aueo])/,'\1\3')                         # ジュ-->jyu-->ju
    #---------------------------------------------------------
    s=s.gsub(/([td])(exy)([aueo])/,'\1h\3')                   # テャ-->texya-->tha
    s=s.gsub(/([td])(ex)([ie])/,'\1\3')                       # ティ-->texi-->ti
    s=s.gsub(/([td])(oxu)/,'\1oo')                            # ドゥ-->toxu-->too
    s=s.gsub(/(tsu)(x)([aiueo])/,'ts\3')                      # ツァ-->tsuxa-->tsa
    s=s.gsub(/([d])(oxy)/,'\1o\'y')                           # ドュ-->doxyu-->doyu
    #---------------------------------------------------------
    s=s.gsub(/(vux)([aieo])/ ,'v\2')                          # ヴァヴィヴェヴォ, ヴァ-->vuxa-->va
    s=s.gsub(/(vuxy)([aueo])/ ,'vy\2')                        # ヴュ-->vuxyu-->vyu
    s=s.gsub(/(ixe)/ ,'iye')                                  # イェ-->ixe-->iye
    s=s.gsub(/(hoxe)/ ,'howe')                                # ホェ-->hoxe-->howe
    s=s.gsub(/(fux)([aieo])/ ,'f\2')                          # ファフィフェフォ, ファ-->fuxa-->fa
    s=s.gsub(/(fuxy)([aueo])/,'fy\2')                         # フュ-->fuxyu-->fyu
    s=s.gsub(/(ux)([ieo])/, 'w\2')                            # ウァウィウェ, ウァ-->uxa-->wa
    #---------------------------------------------------------
    s=s.strip.gsub(/(xtsu)$/,'h!')                            # Recombine hanging 'っ' followed by EOL
    s=s.gsub(/([aiueo]?)(\-)/, '\1\1')                        # Replace boubiki chars and double preceding vowel
    #---------------------------------------------------------
    # Cleanup specifically for source strings that contain spaces!
    s=s.gsub(/( +)([^a-z|A-z])/, '\2')                        # Remove spaces before any non-alphabetical char
    s=s.gsub(/(n')/,'n')                                      # ン-->nn-->n
    s=s.gsub(/(nn)/,'n')                                      # ン-->nn-->n
    s=s.gsub(/( n)[^a-z|A-Z]?$/,'n')                          # Fix "n" appearing as separate word
    s=s.gsub(/\s{2,}/, ' ')                                   # Remove duplicate spaces!
    #---------------------------------------------------------
    return s
  end

  def rom2kata
    ## THIS LINE DOES NOT WORK IN RECENT RUBY VERSIONS!!!    r=""; w=[]; chars=str.split(//e)
    result="" 
    word_buffer=[]
    chars=self.each_char.collect{|c| c}
    loop do
      case word_buffer.size
        ##### When 0 characters in the buffer
      when 0 then
        if chars.size > 0
          word_buffer.push(chars.shift) 
        else
          return result
        end
        ##### Patterns with 1 roman character
      when 1 then
        if word_buffer[0] =~ /[aiueo-]/
          result += Rom2KataH1[word_buffer[0]]
          word_buffer = [] # a-->ア
        elsif word_buffer[0] =~ /[xkcgszjtdnhbpvfmyrlw']/
          if chars.size > 0
            word_buffer.push(chars.shift)
          else 
            return result + (word_buffer[0].gsub(/n/,"ン")) 
          end
        else 
          result += word_buffer.shift
        end
        ##### Patterns with 2 roman characters
      when 2 then    
        if Rom2KataH2.key?(word_buffer.join)
          result += Rom2KataH2[word_buffer.join]
          word_buffer = []
        elsif word_buffer.join =~ /([kgszjtcdnhbpmrl]y)|([stcd]h)|ts|(x[wytk])/ # goto 3
          if chars.size > 0
            # Consume next letter from source array
            word_buffer.push(chars.shift)
          else 
            return result + (word_buffer.join.gsub(/n/,"ン"))
          end
        elsif word_buffer.join == "n'"
          result += "ン"
          word_buffer.shift(2) # n'--> ン
        elsif word_buffer[0] == "n" 
          result += "ン"
          word_buffer.shift # nk-->ンk
        elsif word_buffer[0] == word_buffer[1]
          result += "ッ"
          word_buffer.shift # kk-->ッk
        else 
          result += word_buffer.shift;
        end
        ##### Patterns with 3 roman characters
      when 3 then
        if Rom2KataH3.key?(word_buffer.join)
          result += Rom2KataH3[word_buffer.join] 
          word_buffer=[]
        elsif word_buffer[0] == "n" 
          result += "ン"
          word_buffer.shift
        else 
          result += word_buffer.shift
        end
      end
    end
  end

  def kata2hira(str)
    s=""; str.each_char{|c| s+=( Kata2hiraH.key?(c) ? Kata2hiraH[c] : c )}
    s.normalize_double_n!
    return s
  end

  def hira2kata(str)
    s=""; str.each_char{|c|if(Hira2kataH.key?(c))then s+=Hira2kataH[c];else s+=c; end}
    return s
  end

  def normalize_double_n
    self.gsub(/n\'(?=[^aiueoyn]|$)/, "n")
  end

  def normalize_double_n!
    self.gsub!(/n\'(?=[^aiueoyn]|$)/, "n")
    self
  end

  # Added by Paul 2009-05-12 22:31
  def kana2kana(str1)
    result = []
    str2 = Kana2rom::hira2kata(str1)
    str3 = Kana2rom::kata2hira(str1)
    result << str1
    result << str2 if str2.length > 0 and str1 !=str2
    result << str3 if str3.length > 0 and str2 !=str3 and str3 != str1
    return result
  end

  def rom2hira
    return kata2hira(rom2kata)
  end

  def is_kana?
    if HiraganaCharacters.include?(self) == TRUE || KatakanaCharacters.include?(self) == TRUE
      return true
    end
    return false
  end

  def is_kanji?
    if HiraganaCharacters.include?(self) == FALSE && KatakanaCharacters.include?(self) == FALSE
      return true
    end
    return false
  end

  def is_only_kana?
    self.each_char do |character|
      if HiraganaCharacters.include?(character) == FALSE && KatakanaCharacters.include?(character) == FALSE
        return false
      end
    end
    return true
  end

  def contains_kana?
    self.each_char do |character|
      if HiraganaCharacters.include?(character) == TRUE || KatakanaCharacters.include?(character) == TRUE
        return true
      end
    end
    return false
  end

  alias :to_hiragana :rom2hira
  alias :to_katakana :rom2kata
  alias :to_romaji :kana2rom

end

class String
  include Kana2rom
end