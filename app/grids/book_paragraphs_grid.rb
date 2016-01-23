class BookParagraphsGrid

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
    BookParagraph.includes(:book_sentences => {:source_sentences => :target_sentences}).
                  joins(:book_sentences => {:source_sentences => {:target_sentences => {:book_paragraph => {:book_section => {:book_part => [:book]}}}}}).
                  joins(:book_section => {:book_part => [:book]}).
                  distinct.order('source_sentences_book_sentences.id').limit(3)
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

  column(:translator, :header => 'Çevirmen')
  column(:content, :header => 'Erek Metin') do |model|
    content = prepare_content_for(model)

    String.new.tap do |s|
      s << '<p>'
      content.each do |row|
        next if row.key?(:unaligned)
        colour = case row[:src].length
                 when 0
                  'FF0000' # RED
                 when 1
                   # pass
                 else
                   row[:col]
                 end
        s << "<b#{colour.blank? ? '' : ('style=background-color:' + colour)}>"
        s << row[:loc] << ': </b>' << row[:raw] << '<br />'
      end
      s << '</p>'
    end
  end
  column(:source, :header => 'Kaynak Metin') do |model|
    content = prepare_content_for(model)

    String.new.tap do |s|
      s << '<p>'
      content.each do |row|
        next if row[:src].blank?
      end

      s << Array.new.tap { |a|
        model.book_sentences.each do |target_sentence|
          c = colours.next
          source_sentences = target_sentence.source_sentences(:only => :raw_content)
          next if source_sentences.blank?
          source_sentences.each do |source_sentence|
            a << [source_sentence.target_sentences.reject{|t| t.translator != target_sentence.translator}.map(&:location).sort,
                  source_sentence.raw_content]
          end
        end
      }.sort_by{|i| i[0]}.map{|item|
        "<b>#{item[0].blank? ? 'X' : item[0].join(',')}: </b>#{item[1].gsub('\\', '')}<br />"
      }.join
      s << '</p>'
    end
  end

  def column_class(book_paragraph)
    'book_paragraph'
  end

  def prepare_content_for(book_paragraph)
    @content ||= Hash.new

    source_paragraph = book_paragraph.book_sentences.reject{|s| s.source_sentences.blank?}.map{|s| s.source_sentences.map(&:book_paragraph)}.flatten.uniq.sort_by(&:id).first
    c = [book_paragraph.book_sentences.count, source_paragraph.sentences.count].max

    @content[book_paragraph.id] ||= Array.new(c).tap do |a|
      colours = COLOURS.cycle

      c.times do |idx|
        align = Array.new(2).tap do |ali|
          dst = book_paragraph.book_sentences[idx]
          src = source_paragraph.book_sentences[idx]

          if dst.blank?
            ali[0] << nil
          end
          if src.blank?
            ali[1] << nil
          end


        book_paragraph.book_sentences.each_with_index do |target_sentence, idx|
        h[:dst][idx] = {:col => colours.next, :raw => target_sentence.raw_content.gsub('\\', '')}

        source_sentences = target_sentence.source_sentences
        source_paragraph_aligned |= source_sentences.map(&:id)
        h[:src][idx] = source_sentences.map{|ss| [ss.id, ss.raw_content.gsub('\\', '')}
      end
      h[:unaligned] = Array.new.tap do |src|
        source_paragraphs.map(&:book_sentences).flatten.reject{|x| source_sentences_aligned
      end
      source_p
      a << {:unaligned => Set.new(BookSentence.find(source_paragraph_aligned.first).book_paragraph.book_sentences.select('book_sentences.id').map(&:id)) - source_paragraph_aligned}
    end
  end
end
