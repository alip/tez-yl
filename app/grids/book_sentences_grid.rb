class BookSentencesGrid

  include Datagrid

  scope do
    BookSentence.includes(:source_sentences)
  end

  filter(:translator, :enum,
         :header => 'Çevirmen',
         :default => 'Celâl Üster',
         :select => Book::TRANSLATORS.values) do |name|
           by(Book::TRANSLATORS.first{|k,v| name == v}.first)
         end
  filter(:target_search, :string,
         :header => 'Erek Metin Ara') do |value|
          where('raw_content LIKE ?', value)
         end
  filter(:source_search, :string,
         :header => 'Kaynak Metin Ara') do |value|
          joins(:source_sentences).where(['source_sentences_book_sentences.raw_content LIKE ?', value])
         end

  MODIFICATIONS = {:add => 'Ekleme',
                   :sub => 'Çıkarma',
                   :mul => 'Birleştirme',
                   :div => 'Bölme'}.freeze
  filter(:modifications, :enum,
         :header => 'Değiştirmeler',
         :checkboxes => true,
         :select => MODIFICATIONS.values) do |values|
            joins(:source_sentences => :target_sentences).group('book_sentences.id').having(Array.new.tap { |have|
              values.each { |value|
                puts value.inspect, MODIFICATIONS.invert[value].inspect
                case MODIFICATIONS.invert[value]
                when :add
                  have << '(length(book_sentences.content) >= sum(length(source_sentences_book_sentences.content)))'
                when :sub
                  have << '(length(book_sentences.content) =< sum(length(source_sentences_book_sentences.content)))'
                when :mul
                  have << '(count(distinct book_translations.source_id) > 1)'
                when :div
                  have << '(count(distinct target_sentences_book_sentences.id) > 1)'
                end
              }
            }.join(' or '))
          end

=begin
  filter(:language, :enum,
         :header => 'Dil',
         :select => Book::LANGUAGES.values) do |name|
           includes(:source_sentences).in_language(Book::LANGUAGES.first{|k,v| name == v}.first)
         end
=end

=begin
  filter(:sentence_length, :enum,
         :header => 'Cümle Uzunluğu',
         :select => ['Erek >= Kaynak', 'Kaynak >= Erek'] do |name|
         end
=end

  column(:translator, :header => 'Çevirmen')
  column(:content, :header => 'Erek Metin') { |model| model.raw_content.gsub('\\', '') }
  column(:source, :header => 'Kaynak Metin') { |model| model.source(:only => :raw_content).andand.join("\n").gsub('\\', '') }
=begin
  column(:location, :header => 'Yer') { |model| model.pretty_location }
=end

  def column_class(book_sentence)
    'book_sentence'
  end
end
