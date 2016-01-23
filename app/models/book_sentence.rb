# == Schema Information
#
# Table name: book_sentences
#
#  id                :integer          not null, primary key
#  book_paragraph_id :integer
#  location          :integer
#  content           :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  raw_content       :text
#
# Indexes
#
#  index_book_sentences_on_book_paragraph_id  (book_paragraph_id)
#

class BookSentence < ActiveRecord::Base
  belongs_to :book_paragraph
  has_and_belongs_to_many :book_words

  has_many :sources, :class_name => 'BookTranslation', :foreign_key => :target_id
  has_many :targets, :class_name => 'BookTranslation', :foreign_key => :source_id
  has_many :source_sentences, :through => :sources
  has_many :target_sentences, :through => :targets

  scope :in, -> (language) { includes(:book_paragraph => {:book_section => {:book_part => [:book]}}).where(:books => Book.query_in(language)) }
  scope :by, -> (author_or_translator) { joins(:book_paragraph => {:book_section => {:book_part => [:book]}}).where(:books => Book.query_by(author_or_translator)) }
  scope :has_words, -> (words) { joins(:book_words).where(:book_words => {:content => words}) }
  scope :has_lemmas, -> (lemmas) { joins(:book_words).where(:book_words => {:lemma => lemmas}) }
  scope :in_section, -> (section_id) { includes(:book_paragraph).where(:book_section_id => section_id) }
  scope :not_tagged, -> { joins(:book_words).where(:book_words => {:pos => nil}) }

  # Calculate Type/Token ratio
  def ttr(options = {:unique => false})
    count_arg = "distinct(book_words.#{options[:unique] ? 'content' : 'id'})"

    tokens = tt[:tokens].count
    types  = tt[:types].count(count_arg)

    types.fdiv(tokens)
  end
  def uttr; ttr(:unique => true); end

  def tt
    @tt ||= {:types  => book_words.where(:pos => BookWord::POS.values.flatten),
             :tokens => book_words}
  end

  def aligned?
    !sources.empty?
  end

  def tagged?
    book_words.reject{|w| w.clean_content.nil?}.select{|w| w.pos.blank?}.empty?
  end

  def untagged_words
    book_words.select{|w| w.pos.blank?}
  end

  def tag!
    book_words.reject{|w| w.clean_content.nil?}.each_with_index do |word, idx|
      puts "#{idx}: #{word.raw_content}"
      info = tags[idx]

      word.pos    = info[:pos] unless info[:pos].blank?
      word.pos_v  = info[:pos_v].join('|') unless info[:pos_v].blank?
      word.entity = info[:entity] unless info[:entity].blank?

      unless info[:pos].blank? || info[:stem].blank?
        word.stem  = info[:stem]
        word.lemma = info[:pos] == 'Verb' ? info[:stem] : nil
      end
      word.native = info[:isturkish]

      word.save! if word.changed?
    end
  end

  def tags
    @tags ||= Itu::Nlp.named_entities(book_words.map(&:clean_content).compact)
  end

  # Output in a format suitable for alignment with hunalign.
  def to_hunalign
    words = book_words.select([:id, :content, :location, :stem]).order(:location => :asc)

    # Validate correct tagging.
    no_stem = words.select{|w| w.stem.nil?}.reject{|w| w.clean_content.nil?}
    unless no_stem.empty?
      raise RuntimeError, "Sentence #{id} has untagged words: #{no_stem.map{|w| {:id => w.id, :loc => w.location}}.inspect}"
    end

    # All OK, join and return stems.
    words.map(&:stem).join(' ').gsub('\\', '')
  end

  def likely_translations_in(other_book_paragraph)
    fail 'not source' unless is_source?

    other_book_paragraph.book_sentences.map{|target_sentence| [target_sentence, translation_likely?(target_sentence)]}.reject{|x| x[1] == 0}.sort_by{|x| x[1]}.map{|x| x[0]}.reverse.take(3)
  end

  def translation_likely?(other_sentence)
    if is_source?
      src = self
      dst = other_sentence
    else
      dst = self
      src = other_sentence
    end

    dst_point = 0
    dst_words = dst.content.split(/\W+/).reject{|w| w.length <= 3}.map(&:downcase)

    src.translation_probabilities_for(dst).each do |source_word, translation_probabilities|
      translation_probabilities.to_a.sort_by{|x| x[1]}.reverse.each do |target_data|
        target_word = target_data[0]
        probability = target_data[1]
        if dst_words.include?(target_word)
          dst_point += probability
          break
        end
      end
    end

    dst_point
  end

  def translation_probabilities_for(other_sentence)
    if is_source?
      src = self
      dst = other_sentence
    else
      dst = self
      src = other_sentence
    end

    names = Set.new(src.book_words.select{|w| w.pos.start_with?('N')}.map{|w| w.content}.reject{|c| c.length <= 3})
    verbs = Set.new(src.book_words.select{|w| w.pos.start_with?('V')}.map{|w| w.lemma}.reject{|l| ['be', 'have'].include?(l)})
    words = names # (names | verbs)

    translation_probabilities = Hash.new.tap do |tpr|
      words.each do |name|
        if names.include?(name)
          word_q = ['book_words.content IN (?)', [name, name.singularize, name.pluralize].uniq]
        else # verb
          word_q = ['book_words.lemma = ?', name]
        end

        tpr[name] = Hash.new.tap do |tpr_name|
          BookSentence.by(dst.translator).joins(:source_sentences => [:book_words]).
                       where(*word_q).where.not(:book_translations => {:source_id => src.id}).each do |target_sentence|
            if names.include?(name)
              target_sentence.content.split(/[\s,.:!?]/).reject{|w| w.length <= 3}.map(&:downcase).each { |target_word|
                tpr_name[target_word] = tpr_name[target_word].to_i + 1 }
            else # verb
              candidates = []
              target_words = target_sentence.content.split(/\s/).reject{|w| w.length <= 3}.map(&:downcase)
              candidates.concat(%w[ve ama belki ancak fakat lakin].select{|x| target_words.include?(x)}.map{|x| target_words[target_words.index(x) - 1]})
              candidates.concat(target_words.select{|w| w =~ /[,.:!?]/}.map{|x| x.gsub(/[,.:!?]/, '')})

              candidates.each { |target_word|
                tpr_name[target_word] = tpr_name[target_word].to_i + 1 }
            end
          end
        end

        # Merge similar items with prefix match & levenshtein distance.
        tpr[name].keys.each do |tpr_key|
          tpr[name].keys.reject{|k| k == tpr_key}.each do |tpr_key_compare|
            next unless tpr[name].key?(tpr_key) && tpr[name].key?(tpr_key_compare)

            c = tpr_key_compare.length <=> tpr_key.length
            if (c >= 0 && tpr_key_compare.start_with?(tpr_key[0...5])) || (c < 0  && tpr_key.start_with?(tpr_key_compare[0...5]))
              tpr[name][tpr_key] += tpr[name].delete(tpr_key_compare)
            end
          end
        end

        # Clean up probabilities with only one hit (false positives)
        tpr[name].reject!{|tpr_key, tpr_count| tpr_count <= 1}
      end
    end
  end

  def source(options = {})
    options[:only] ||= nil # :content, :raw_content

    return nil if translator.blank?

    r = self.source_sentences
    options[:only].nil? ? r : r.map(&:"#{options[:only]}")
  end

  def pretty_location
    sprintf('%02d.%02d.%02d.%02d',
            book_part.location,
            book_section.location,
            book_paragraph.location,
            location)
  end

  def is_source?
    language == :english
  end

  def is_target?
    language != :english
  end

  def language
    @language ||= book.language.to_sym
  end

  def translator
    book.translator
  end

  def book_section
    book_paragraph.book_section
  end

  def book_part
    book_section.book_part
  end

  def book
    book_part.book
  end
end
