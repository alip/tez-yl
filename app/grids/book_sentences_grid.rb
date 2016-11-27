class BookSentencesGrid

  include Datagrid

  COLOURS = %w[FFFF99 FFFF33 FFCCFF FFCC99
               FFCC33 FF99FF FF9999 FF9933 FF66FF
               CCFFCC CCFF66 CCFF00 CCCCFF CCCC99
               CCCC33 CC99FF CC9999 CC9966 99FFCC
               99FF66 99FF00 99CCFF 99CC99 99CC66
               9999FF 66FFCC 66FF66 66FF00 66CCCC
               3399FF 00CC33 0099FF 6666FF 9900FF
               CC00FF CC6633 FF0099 FF6666 FF9900]

  scope do
    BookSentence.includes(:target_sentences).where(:language => 'english')#.where('book_sentences.id > 21466')
  end

  filter(:translator, :enum,
         :prompt => '-- Çevirmen --',
         :checkboxes => true,
         :select => Book::TRANSLATORS.values,
         :dummy => true)

  filter(:target_search, :string,
         :placeholder => 'Erek Metin',
         :header => 'Metin Ara:') do |value, scope, grid|
            if value =~ /\A['"](.*?)['"]\Z/
              value = Regexp.last_match[1]
            elsif value !~ /%/
              value = "%#{value}%"
            end
            s = scope.joins(:target_sentences).where(["target_sentences_book_sentences.raw_content LIKE ?", value])
            unless grid.translator.blank?
              s = s.where(["target_sentences_book_sentences.translator IN (?)", grid.translator])
            end
         end
  filter(:source_search, :string,
         :placeholder => 'Kaynak Metin',
         :header => 'Metin Ara:') do |value|
           op = 'LIKE'
           if value == 'newspeak'
             value = '(Newspeak|Minitrue|Minipax|Miniluv|Miniplenty|duckspeak|facecrime|ownlife|doublethink|artsem|crimethink|crimestop|goodthinker|thoughtcrime|dayorder|doubleplusungood|unperson|upsub|antefiling|prole|IngSoc|Anti-Sex|Junior Anti-Sex League|Pornosec)'
             op    = 'RLIKE'
           elsif value =~ /\A['"](.*?)['"]\Z/
             value = Regexp.last_match[1]
           elsif value !~ /%/
             value = "%#{value}%"
           end
           where(["book_sentences.raw_content #{op} ?", value])
         end

  SENT_MOD = {:mul => 'Birleştirme',
              :div => 'Bölme',
              :del => 'Çıkarma'}.freeze
  filter(:sentmod, :enum,
         :include_blank => '-- Cümle Değiştirme --',
         :select => SENT_MOD.values) do |value, scope, grid|
             t = grid.andand.translator.andand.first
             case SENT_MOD.invert[value]
             when :mul
               x = BookTranslation.group(:target_id).having('count(source_id) > 1').select(:source_id).map(&:source_id)
               where(:id => x)
             when :div
               scope.where(:id => BookTranslation.joins(:target_sentence).where(:book_sentences => Book.query_by(t)).group(:source_id).having('count(target_id) > 1').pluck(:source_id))
             when :del
               x = BookTranslation.group(:source_id).having('count(target_id) < 3').select(:source_id).map(&:source_id)
               where(:id => x)
             end
          end

  SHIFTS = {#:passivisation        => 'Etken   -> Edilgen',
            #:depassivisation      => 'Edilgen -> Etken',
            :pronominalisation    => 'İsim    -> Zamir',
            :depronominalisation  => 'Zamir   -> İsim',
            :exclamation          => 'Ünlem ekleme',
            :deexclamation        => 'Ünlem çıkarma',
            :questionation        => 'Soru işareti ekleme',
            :dequestionation      => 'Soru işareti çıkarma'#,
            #:newspeak             => 'Yenikonuş'
  }
  filter(:shift, :enum,
         :prompt => '-- Kayma --',
         :checkboxes => true,
         :select => SHIFTS.values) do |values, scope, grid|
=begin
      if values.include?('Yenikonuş')
        s = scope.newspeak
      else
        s = scope
      end
=end
      v = values.map{|vv| BookSentence::SHIFTS.index(SHIFTS.invert[vv])}.compact.inject(:|).to_i
      unless v == 0
        s = s.joins(:target_sentences).where("target_sentences_book_sentences.flags & #{v} != 0")
      end
      unless grid.translator.blank?
        s = s.where(["target_sentences_book_sentences.translator IN (?)", grid.translator])
      end
  end

  column(:source, :header => 'Kaynak Metin') do |model|
    ss = model.target_sentences.map(&:source_sentences).flatten.uniq.sort_by(&:id)
    String.new.tap do |s|
      s << '<ul>'
      ss.each do |source_sentence|
        s << "<li style='font-size: 14px;list-style: none;'>#{source_sentence.id}: " << source_sentence.raw_content.gsub('\\', '') << "</li>"
      end
      s << "</ul>"
    end
  end

  column(:content, :header => 'Erek Metin') do |model, grid|
    if grid.translator.blank?
      t = model.target_sentences.sort_by(&:id).group_by(&:translator)
    else
      t = model.target_sentences.select{|x| grid.translator.include?(x.translator)}.sort_by(&:id).group_by(&:translator)
    end

    String.new.tap do |s|
      s << '<ul>'
      t.reject{|k,v| k.nil? || k == 'XXX'}.each do |translator,target_sentences|
        x = COLOURS[Book::TRANSLATORS.values.index(translator)]
        c = target_sentences.map(&:raw_content).join(' ')
        i = "#{target_sentences.map(&:sources).flatten.map(&:source_id).uniq.reject(&:blank?).join(',')}->#{target_sentences.map(&:id).uniq.reject(&:blank?).join(',')}"
        s << "<li style='font-size: 14px;list-style: none;background-color:##{x}'> #{translator} [#{i}]: " << c.gsub('\\', '') << "</li>"
      end
      s << "</ul>"
    end
  end
end
