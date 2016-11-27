# == Schema Information
#
# Table name: book_words
#
#  id               :integer          not null, primary key
#  content          :string(255)
#  lemma            :string(255)
#  pos              :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  raw_content      :text(65535)
#  location         :integer
#  stem             :string(255)
#  pos_v            :string(255)
#  entity           :string(255)
#  native           :boolean
#  auto_content     :text(65535)
#  book_sentence_id :integer
#  stop_word        :boolean          default(FALSE)
#  new_speak        :boolean          default(FALSE)
#  new_naming       :boolean          default(FALSE)
#  new_abbreviation :boolean          default(FALSE)
#
# Indexes
#
#  index_book_words_on_book_sentence_id  (book_sentence_id)
#

class BookWord < ActiveRecord::Base
  POS = {
    :noun      => %w[Noun NN NE NNP NNPS NNS FW FM].freeze,
    :adjective => %w[CARD ADJA Adjective Adj Adj^DB JJ JJR JJS Dup].freeze, # Dup == ikileme
    :adverb    => %w[ADV ADJD Adverb Adverb^DB Adv Adv^DB RB RBR RBS WRB].freeze,
    :verb      => %w[VVFIN VVIMP VVINF VVIZU VVPP Verb VB VBD VBG VBN VBP VBZ].freeze
  }.freeze
  AUX = ['be', 'am', 'is', 'are', 'was', 'were', 'been', 'have', 'has', 'had', 'do', 'does', 'did',
         'sein', 'bin', 'bist', 'ist', 'sind', 'seid', 'war', 'warst', 'waren', 'wart', 'wäre', 'wärest', 'wären', 'wäret', 'sei', 'seist', 'seien', 'seiet',
         'haben', 'habe', 'hast', 'hat', 'habt', 'hatte', 'hattest', 'hatten', 'hattet', 'hätte', 'hättest', 'hätten', 'hättet',
         'werden', 'werde', 'wirst', 'wird', 'werdet', 'wurde', 'wurdest', 'wurden', 'wurdet', 'würde', 'würdest', 'würden', 'würdet']

  # has_and_belongs_to_many :book_sentences
  belongs_to :book_sentence

  scope :in, -> (language) { includes(:book_sentence => [{:book_paragraph => {:book_section => {:book_part => [:book]}}}]).where(:books => Book.query_in(language)) }
  scope :by, -> (author_or_translator) { includes(:book_sentence => [:book_paragraph => {:book_section => {:book_part => [:book]}}]).where(:books => Book.query_by(author_or_translator)) }
  scope :with_type, -> (tag) { where(:pos => POS[tag]) }

  scope :passive_verb, -> { with_type(:verb).where('pos_v LIKE "%|Pass|%"') }
  scope :personal_pronoun, -> { where("pos = 'PRP' or (pos = 'Pron' and pos_v LIKE '%Pers%')") }

  has_many :relateds, :class_name => 'BookWordDependency', :foreign_key => :relater_id
  has_many :relaters, :class_name => 'BookWordDependency', :foreign_key => :related_id
  has_many :related_words, :through => :relateds
  has_many :relater_words, :through => :relaters

  def self.translated_by(pattern, who, nbest: 5, nchunk: 1)
    sentences_words = BookSentence.includes(:target_sentences => :book_words).by(:orwell).in(:english).joins(:book_words).where(['book_sentences.content RLIKE ?', pattern]).joins(:target_sentences).where(:target_sentences_book_sentences => {:translator => Book::TRANSLATORS[who]}).map{|s| s.target_sentences.includes(:book_words).by(who).map(&:tokens).flatten.reject{|word| %w[ein der die das dem den des bir und ve fur mit für sich].include?(word.stem) || %w[Punc DT WDT ART].include?(word)}}
    Hash.new.tap do |token_frequency|
      sentences_words.each do |sentence_words|
        sentence_words.collocation(nchunk) do |chunk|
          cc = chunk.map(&:stem).join(' ').downcase
          token_frequency[cc] ||= Hash.new
          token_frequency[cc][:count] = token_frequency[cc][:count].to_i + 1
          token_frequency[cc][:words] ||= Set.new
          token_frequency[cc][:words] << chunk.map(&:raw_content).join('+')
          token_frequency[cc][:word_ids] ||= Set.new
          token_frequency[cc][:word_ids] |= chunk.map(&:id)
        end
      end
    end.sort_by{|k,v| v[:count].fdiv(sentences_words.count)}.reverse[0...nbest]
  end

  # Clever unique function for TTR
  def self.uniq(words, stem: false)
    stem ? words.uniq{|w| (w.stem || w.lemma).andand.downcase.tr('-\\*…“”', '').gsub(/’[^’]+\Z/, '').gsub(/[‘+’]/, "").gsub('û', 'u').gsub('â', 'a')} \
         : words.uniq{|w| w.clean_content.downcase}
  end

  def dependencies
    BookWordDependency.where(:relater_id => id).map{|wd| [wd.dependency, wd.related_word]}.to_h
  end

  def personal_pronoun?
    pos == 'PRP' || (pos == 'Pron' && pos_v =~ /Pers/)
  end

  def root
    verb? ? self.lemma : self.stem
  end

  def self.type?(word_pos, word_content)
    case word_pos
    when *BookWord::POS[:noun]
      true
    when *BookWord::POS[:verb]
      true
    when *BookWord::POS[:adjective]
      true
    when 'RB'
      if ['not', 'nicht'].include?(word_content.downcase)
        false
      else
        true
      end
    when *BookWord::POS[:adverb]
      true
    else
      false
    end
  end

  def type?
    # Special cases
    return false if clean_content.nil?
    return false if ['noone', 'anyone', 'someone', 'everyone', 'anything', 'something', 'everything', 'nothing'].include?(clean_content)
    return false if [clean_content, stem].any?{|w| w.andand.start_with?('şey') || (pos == 'Verb' && ['ol', 'et'].include?(w))}
    return false if ['a', 'an', 'as', 'eh', 'd', 'em', 'the'].include?(clean_content.downcase)
    return false if ['i', 'it', 'don', 'we', 'you', 'he', 'she', 'they', 'isn', 'aren'].include?(clean_content.downcase)
    return false if pos == 'ADV' && ['doch'].include?(clean_content.downcase)
    return false if pos == 'Adj' && pos_v == 'Num' && content.downcase == 'bir'
    return false if pos == 'JJ' && pos_v.andand.include?('NP') && !stem.nil? && ['ich', 'du', 'er', 'sie', 'es', 'wir', 'ihr'].include?(stem)
    return false if pos == 'Verb' && pos_v.include?('Adj') && stem == 'ol'
    return false if aux?
    return false if ['nicht', 'nichts'].include?(clean_content.downcase)
    return true  if pos == 'Adj' && pos_v == 'Num'
    return true  if pos == 'CD'

    case pos
    when nil
      false
      #fail "word #{id} not tagged"
    when 'IN'
      if pos_v.andand.include?('NP') && !stem.nil? && (stem.end_with?('lich') || ['gleichzeitig', 'erst', 'niemals', 'nie', 'wenigstens', 'besonders', 'jetzt', 'wenig', 'nun', 'ungeachtet', 'vielleicht', 'ähnelte', 'brach', 'immer', 'morgen', 'leicht', 'überhaupt', 'genauer', 'kraft', 'natürliche', 'natürlichen', 'wert', 'ängst'].include?(stem))
        true
      else
        false
      end
    when *BookWord::POS[:verb]
      if pos_v.andand.include?('VP') && !lemma.nil? && ['dürfen', 'können', 'mögen', 'wollen', 'möchten', 'müssen', 'sollen'].include?(lemma)
        false
      else
        BookWord.type?(pos, content)
      end
    when 'Guess'
      guess = pos_v.andand.split('|')
      if guess.blank?
        false
      else
        BookWord.type?(guess.select{|x| x != 'Guess'}.first, content)
      end
    else
      BookWord.type?(pos, content)
    end
  end

  def noun?
    POS[:noun].include?(self.pos)
  end

  def adjective?
    POS[:adjective].include?(self.pos)
  end

  def adverb?
    POS[:adverb].include?(self.pos)
  end

  def verb?
    POS[:verb].include?(self.pos)
  end

  def aux?
    (['ADJD', 'ADV', 'RB'].include?(self.pos) || POS[:verb].include?(self.pos)) && [content.downcase, stem.andand.downcase].compact.any?{|x| AUX.include?(x)}
  end

  def clean_content
    r = (raw_content || content).gsub('û', 'u').gsub('â', 'a')# .tr('ÖÜİÇŞĞ', 'öüiçşğ')

    o = %w[! \\ . » « - – ’ ‘ “ ” … *]
    unless r.chars.reject{|c| o.include?(c)}.empty?
      r.gsub!('.', '')
      r.gsub!('»', '')
      r.gsub!('«', '')
      r.gsub!('-', '')
      r.gsub!('–', '')
      r.gsub!('‘', '')
      r.gsub!('’', '')
      r.gsub!('“', '')
      r.gsub!('”', '')
      r.gsub!('…', '')
      r.gsub!('*', '')
      r.gsub!('\\', '')
    else
      r.gsub!('‘', "'")
      r.gsub!('’', "'")
      r.gsub!('“', '"')
      r.gsub!('”', '"')
      r.gsub!('…', '...')
    end

#    cc = raw_content.gsub('\\', '').tr('“”', '""')
#
#    # Strip quotation, if blank, pass through quotation.
#    scc = cc.gsub(/["']/, '')
#
#    r = (scc.blank? ? cc : scc)
#
#    # Strip plus sign (tele+ekran)
#    r.gsub!('+', '')
#
    # Nilify blanks for easier compact()ion.
    r.blank? ? nil : r
  end
end
