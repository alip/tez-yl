class BookSentencesGrid

  include Datagrid

  COLOURS = %w[FFFFFF FFFF99 FFFF33 FFCCFF FFCC99
               FFCC33 FF99FF FF9999 FF9933 FF66FF
               CCFFCC CCFF66 CCFF00 CCCCFF CCCC99
               CCCC33 CC99FF CC9999 CC9966 99FFCC
               99FF66 99FF00 99CCFF 99CC99 99CC66
               9999FF 66FFCC 66FF66 66FF00 66CCCC
               3399FF 00CC33 0099FF 6666FF 9900FF
               CC00FF CC6633 FF0099 FF6666 FF9900]

  scope do
    BookSentence.joins(:source_sentences => {:target_sentences => {:book_paragraph => {:book_section => {:book_part => [:book]}}}}).
                 joins(:book_paragraph => {:book_section => {:book_part => [:book]}}).
                 distinct
  end

  filter(:translator, :enum,
         :prompt => '-- Çevirmen --',
         :select => Book::TRANSLATORS.values) do |name|
           q = Book.query_by(Book::TRANSLATORS.detect{|k,v| name == v}.first)
           where(:books => q, :books_book_parts => q)
         end
  filter(:target_search, :string,
         :placeholder => 'Erek Metin',
         :header => 'Metin Ara:') do |value|
            if value =~ /\A['"](.*?)['"]\Z/
              value = Regexp.last_match[1]
            elsif value !~ /%/
              value = "%#{value}%"
            end
            where(['target_sentences_book_sentences.raw_content LIKE ?', value])
         end
  filter(:source_search, :string,
         :placeholder => 'Kaynak Metin',
         :header => 'Metin Ara:') do |value|
           if value =~ /\A['"](.*?)['"]\Z/
             value = Regexp.last_match[1]
           elsif value !~ /%/
             value = "%#{value}%"
           end
           where(['source_sentences_book_sentences.raw_content LIKE ?', value])
         end

  SENT_MOD = {:mul => 'Birleştirme',
              :div => 'Bölme'}.freeze
  filter(:sentmod, :enum,
         :prompt => '-- Cümle Değiştirme --',
         :select => SENT_MOD.values) do |value|
             case SENT_MOD.invert[value]
             when :mul
               group('book_sentences.id').having('(count(distinct source_sentences_book_sentences.id) > 1)')
             when :div
               where(:id => group('source_sentences_book_sentences.id').having('(count(distinct target_sentences_book_sentences.id) > 1)').select('target_sentences_book_sentences.id').map(&:id))
             end
          end

=begin
  MODIFICATIONS = {:add => 'Ekleme',
                   :sub => 'Çıkarma',
                   :mul => 'Birleştirme',
                   :div => 'Bölme'}.freeze
  filter(:modifications, :enum,
         :prompt => '-- Değiştirme --',
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
=end

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

  column(:align, :header => 'Eş') do |model|
    "<input name='align-#{model.id}' value='#{model.sources.map(&:source_id).join(' ')}'></input>"
  end

  # column(:translator, :header => 'Çevirmen')
  column(:content, :header => 'Erek Metin') do |model|
    "#{model.id}: #{model.raw_content}"
=begin
    colours = COLOURS.cycle
    String.new.tap do |s|
      s << "<ol>"
      model.book_paragraph.book_sentences.each do |target_sentence|
        t = target_sentence.raw_content
        s << "<li style='background-color:##{colours.next}'>" << t.gsub('\\', '') << "</li>"
      end
      s << "</ol>"
    end
=end
  end
  column(:source, :header => 'Kaynak Metin') do |model|
    colours = COLOURS.cycle
    String.new.tap do |s|
      s << "<ul>"
      model.source_sentences.each do |source_sentence|
        t = source_sentence.raw_content
        s << "<li style='list-style: none;background-color:##{colours.next}'> #{source_sentence.id}: " << t.gsub('\\', '') << "</li>"
      end
      s << "</ul>"
    end

=begin
    colours = COLOURS.cycle
    String.new.tap do |s|
      s << "<ol>"
      model.book_paragraph.book_sentences.each do |target_sentence|
        t = target_sentence.raw_content
        s << "<li style='background-color:##{colours.next}'>" << t.gsub('\\', '') << "</li>"
      end
      s << "</ol>"
    end
=end
  end

=begin
  column(:location, :header => 'Yer') { |model| model.pretty_location }
=end

  def column_class(book_sentence)
    'book_sentence'
  end
end
