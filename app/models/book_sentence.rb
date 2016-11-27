# == Schema Information
#
# Table name: book_sentences
#
#  id                :integer          not null, primary key
#  book_paragraph_id :integer
#  location          :integer
#  content           :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  raw_content       :text(65535)
#  auto_content      :text(65535)
#  translator        :string(255)
#  language          :string(255)
#  author            :string(255)
#  shifts            :integer
#  flags             :integer
#  ttr_section       :integer
#  ttr_subsection    :integer
#
# Indexes
#
#  index_book_sentences_on_book_paragraph_id  (book_paragraph_id)
#

class BookSentence < ActiveRecord::Base
  belongs_to :book_paragraph
  has_many :book_words, :dependent => :destroy
  #has_and_belongs_to_many :book_words, :dependent => :destroy

  has_many :sources, :class_name => 'BookTranslation', :foreign_key => :target_id
  has_many :targets, :class_name => 'BookTranslation', :foreign_key => :source_id
  has_many :source_sentences, :through => :sources
  has_many :target_sentences, :through => :targets

  scope :in, -> (language) { includes(:book_paragraph => {:book_section => {:book_part => [:book]}}).where(:books => Book.query_in(language)) }
  scope :by, -> (author_or_translator) { where(**Book.query_by(author_or_translator)) }
  scope :has_words, -> (words) { joins(:book_words).where(:book_words => {:content => words}) }
  scope :has_lemmas, -> (lemmas) { joins(:book_words).where(:book_words => {:lemma => lemmas}) }
  scope :in_section, -> (section_id) { includes(:book_paragraph).where(:book_section_id => section_id) }
  scope :not_tagged, -> { joins(:book_words).where(:book_words => {:pos => nil}) }
  scope :newspeak, -> { # FIXME: quick hack.
    value = '(Newspeak|Minitrue|Minipax|Miniluv|Miniplenty|duckspeak|facecrime|ownlife|doublethink|artsem|crimethink|crimestop|goodthinker|thoughtcrime|dayorder|doubleplusungood|unperson|upsub|antefiling|prole|IngSoc|Anti-Sex|Junior Anti-Sex League|Pornosec)'
    where(:language => 'english').where(['raw_content RLIKE ?', value])
  }

  FLAGS  = [:passive,
            :personal_pronoun,
            :exclamation,
            :question,
            :explanation
  ].freeze

  scope :passive, -> { where("flags = (flags | 1 << #{FLAGS.index(:passive)})") }
  scope :active, -> { where("flags != (flags | 1 << #{FLAGS.index(:passive)})") }

  SHIFTS = [:passivisation,
            :depassivisation,
            :pronominalisation,
            :depronominalisation,
            :exclamation,
            :deexclamation,
            :questionation,
            :dequestionation
  ].freeze

  def self.wrap(sentences)
    words = sentences.map do |s|
      s.raw_content.split(' ').map do |w|
        s.types.any? do |t|
          l = [4, t.content.length].min
          t.content[0..l] == w[0..l].downcase
        end ? '\e'"mph{#{w}}" : w
      end
    end.flatten

    i = 0
    lines = [[]]
    words.each do |raw_word|
      w = raw_word.start_with?('\emph{') ? raw_word[6..-2] : raw_word
      if lines[i].map{|word| word.start_with?('\emph{') ? word[6..-2] : word}.join(' ').length + 1 + w.length > 72
        i += 1
        lines[i] = []
      end
      lines[i] << raw_word
    end
    lines.map{|x| x.join(' ')}.join('\\\\ ')
  end

  def translation_split?
    source_sentences.any?{|ss|
      t = ss.target_sentences.includes(:sources).by(translator)
      t.to_a.count > t.map(&:sources).flatten.count
    }
  end

  def flag_set?(f)
    (self.flags & (1 << FLAGS.index(f))) == 1
  end

  def passive?
    (self.flags & (1 << FLAGS.index(:passive))) == 1
  end

  def self.merge!(*sentence_ids)
    sentences = sentence_ids.uniq.sort.map{|sid| BookSentence.find(sid)}

    dst = sentences.first
    src = sentences[1..-1]
    lng = dst.language

    src.each do |src_sent|
      %i[content raw_content auto_content].each do |c|
        new_content = dst.send(c).andand.clone.to_s
        old_content = src_sent.send(c).andand.clone.to_s
        next if old_content.blank?

        if !new_content.end_with?(' ') && !old_content.start_with?(' ')
          new_content << ' '
        end
        new_content << old_content
        dst.send(:"#{c}=", new_content)
      end

      BookWord.where(:id => src_sent.book_words.pluck(:id)).update_all(:book_sentence_id => dst.id)

      unless lng == :english
        src_sent.source_sentences.each do |source_sentence|
          BookTranslation.find_or_create_by(:source_id => source_sentence.id,
                                            :target_id => dst.id)
          BookTranslation.delete_all(['source_id = ? AND target_id = ?', source_sentence.id, src_sent.id])
        end
      else
        src_sent.target_sentences.each do |target_sentence|
          BookTranslation.find_or_create_by(:target_id => target_sentence.id,
                                            :source_id => dst.id)
          BookTranslation.delete_all(['source_id = ? AND target_id = ?', src_sent.id, target_sentence.id])
        end
      end
    end

    dst.save!
    src.each {|sent| sent.destroy! }

    dst
  end

  def align_window_begin
    BookSentence.by(self.translator).joins(:source_sentences).where(['book_sentences.id < ?', self.id]).order('source_sentences_book_sentences.id DESC').select('source_sentences_book_sentences.id').first.andand.id
  end

  def align_window_end
    BookSentence.by(self.translator).joins(:source_sentences).where(['book_sentences.id > ?', self.id]).order('book_sentences.id,source_sentences_book_sentences.id ASC').select('source_sentences_book_sentences.id').first.andand.id
  end

  def aligned?
    !sources.empty?
  end

  # Fix quote word in sentences like:
  # "»bringen sie die gläser hierher, martin."
  # where the first book word is: "»bringen"
  def fix_quote!
    nw = BookWord.create(:content => '»', :location => 1)
    self.book_words.append(nw)
    ws = book_words.order(:location)
    ws.each_with_index do |w, idx|
      next if w.id == nw.id
      w.location += 1
      if w.location == 2 and w.content.start_with?('»')
        w.content = w.content[1..-1]
        w.raw_content = w.raw_content[1..-1]
        w.stem = w.stem[1..-1]
      end
      w.save!
    end
  end

  def translate!(translator)
    return nil unless self.auto_content.nil?
    self.auto_content = translator.translate(content)
    save!
  end

  # Calculate Type/Token ratio
  def tokens(unique: false, limit: nil)
    r = book_words.reject{|w| w.pos == '?' || w.raw_content =~ /\A[[:^alnum:]]\Z/}
    unless limit.to_i > r.count
      unique ? BookWord.uniq(r, :stem => true) : r
    else
      # Pick from between
      off = (r.count - limit) / 2
      r[off...off+limit]
    end
  end

  def types(unique: false, limit: nil)
    r = tokens(:limit => limit).select(&:type?)
    unique ? BookWord.uniq(r, :stem => true) : r
  end

  def type_token_ratio(unique: false, limit: nil)
    if limit.nil?
      token_count = tokens(unique: unique).count
      token_count == 0 ? 0 : types(:unique => unique).count.fdiv(token_count)
    else
      toks = tokens(unique: unique)
      unless limit > toks.length
        off = (toks.count - limit)
        toks = toks[off...off+limit]
      end
      typs = toks.select(&:type?)
      toks.count == 0 ? 0 : typs.count.fdiv(toks.count)
    end
  end

  def uttr; ttr(:unique => true); end

  def tt
    @tt ||= {:types  => book_words.where(:pos => BookWord::POS.values.flatten),
             :tokens => book_words}
  end

  def tagged?
    book_words.reject{|w| w.clean_content.nil?}.select{|w| w.pos.blank?}.empty?
  end

  def untagged_words
    book_words.select{|w| w.pos.blank?}
  end

  # Like tag, but includes dependency parsing too.
  def analyze!
    words = book_words.order(:location).select([:id, :raw_content])
    Itu::Nlp.cts_pipeline(words.map(&:clean_content)).each_with_index do |data, idx|
      word = words[idx]
      word.location = idx + 1
      word.save!
      unless data[:dep].nil?
        relate_idx = data[:dep][:idx]
        related_as = BookWordDependency.dependencies[data[:dep][:as]]
        relater_id = word.id
        related_id = relate_idx >= 0 ? words[relate_idx].id : nil
        BookWordDependency.find_or_create_by(:relater_id => relater_id,
                                             :related_id => related_id,
                                             :dependency => related_as)
      end
    end
  end

  def tag_me!(tagger)
    sent = book_words.reject{|w| w.clean_content.nil?}.map(&:clean_content).join('|')
    puts sent
    tagged = tagger.tag(sent).split('|').map{|x| x.split('/', 1)}
  end

  def tag!
    book_words.reject{|w| w.clean_content.nil?}.each_with_index do |word, idx|
      puts "#{idx}: #{word.raw_content}"
      info = tags[idx]
      next if info.nil?

      word.pos    = info[:pos] unless info[:pos].blank?
      word.pos_v  = info[:pos_v].join('|') unless info[:pos_v].blank?
      word.entity = info[:entity] unless info[:entity].blank?

      unless info[:pos].blank? || info[:stem].blank?
        word.stem  = info[:stem]
        word.lemma = info[:pos] == 'Verb' ? info[:stem] : nil
      end
      #word.native = info[:isturkish]

      word.save! if word.changed?
    end
  end

  def simple_tags
    @simple_tags ||= Itu::Nlp.morphanalyzer(book_words.map(&:clean_content).join(' '))
  end

  def tags
    @tags ||= Itu::Nlp.named_entities(book_words.map(&:clean_content).compact)
  end

  # Output in a format suitable for alignment with hunalign.
  def to_hunalign
    words = book_words.select([:id, :content, :raw_content, :location, :stem]).order(:location => :asc)

    # Validate correct tagging.
    no_stem = words.select{|w| w.stem.nil?}.reject{|w| w.clean_content.nil?}
    unless no_stem.empty?
      raise RuntimeError, "Sentence #{id} has untagged words: #{no_stem.map{|w| {:id => w.id, :loc => w.location}}.inspect}"
    end

    # All OK, join and return stems.
    words.map(&:stem).join(' ').gsub(' \\ ', ' ').gsub('\\', '').gsub(/\*([^*]+)\*/, '\1')
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

  def book_language
    @book_language ||= book.language.to_sym
  end

  def book_author
    book.author
  end

  def book_translator
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
