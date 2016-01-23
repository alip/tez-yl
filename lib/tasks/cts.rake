namespace :cts do
  desc 'Rebuild database from scratch with base data'
  task :rebuilddb => [
    'db:drop',
    'db:create',
    'db:migrate',
    'db:seed'
  ]

  desc 'Write hunalign stem files'
  task :prep_hunalign => :environment do
    %i[orwell akgoren uster].each do |author|
      File.open(Rails.root.join("align/1984-#{author}.stem").to_s, 'w') do |f|
        BookParagraph.by(author).order(:id => :asc).includes(:book_sentences => :book_words).each do |p|
          $stderr.puts p.id
          f.print p.to_hunalign
        end
      end
    end
  end

  desc 'Graph for Type/Token ratio(s)'
  task :draw_ttr => :environment do
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.terminal 'png size 1024,640'
        plot.output Rails.root.join('plot/1984-ttr.png').to_s

        plot.title  '1984: Çeşit/Örnekçe Oranı'
        plot.xlabel 'Bölüm (#)'
        plot.ylabel 'Çeşit/Örnekçe (%)'

        plot.key 'autotitle columnhead'
        plot.xrange '[0:27]'
        plot.yrange '[42:72]'
        plot.xtics  '1'
        plot.ytics  '2'
        plot.grid

        # %uster
        %i[orwell akgoren].each do |author|
          ttr_path = Rails.root.join("plot/1984-ttr-#{author}.dat").to_s
          if File.exist?(ttr_path)
            ttr = File.readlines(ttr_path).map{|line| line.strip.to_f}
          else
            ttr = Array.new.tap do |ta|
              BookSection.by(author).each {|book_section|
                ta << book_section.book_paragraphs.includes(:book_sentences).map { |book_paragraph|
                  book_paragraph.book_sentences.includes(:book_words).
                    map(&:ttr).
                    inject(:+).
                    fdiv(book_paragraph.book_sentences.count)
                }.inject(:+).fdiv(book_section.book_paragraphs.count)
              }
            end
            File.open(ttr_path, 'w') do |f|
              f.puts ttr.map(&:to_s).join("\n")
            end
          end

          x   = (0...ttr.count).to_a
          y   = x.map{|v| ttr[v] * 100}

          plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
            ds.with = 'linespoints'
            ds.title = author.capitalize
          end
        end
      end
    end
  end

  desc 'Graph for Type/Token ratio(s)'
  task :draw_uttr => :environment do
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.terminal 'png size 1024,640'
        plot.output Rails.root.join('plot/1984-uttr.png').to_s

        plot.title  '1984: Tekil Çeşit/Örnekçe Oranı'
        plot.xlabel 'Bölüm (#)'
        plot.ylabel 'Tekil Çeşit/Örnekçe (%)'

        plot.key 'autotitle columnhead'
        plot.xrange '[0:27]'
        plot.yrange '[42:72]'
        plot.xtics  '1'
        plot.ytics  '2'
        plot.grid

        # %uster
        %i[orwell akgoren].each do |author|
          ttr_path = Rails.root.join("plot/1984-uttr-#{author}.dat").to_s
          if File.exist?(ttr_path)
            ttr = File.readlines(ttr_path).map{|line| line.strip.to_f}
          else
            ttr = Array.new.tap do |ta|
              BookSection.by(author).each {|book_section|
                ta << book_section.book_paragraphs.includes(:book_sentences).map { |book_paragraph|
                  book_paragraph.book_sentences.includes(:book_words).
                    map(&:uttr).
                    inject(:+).
                    fdiv(book_paragraph.book_sentences.count)
                }.inject(:+).fdiv(book_section.book_paragraphs.count)
              }
            end
            File.open(ttr_path, 'w') do |f|
              f.puts ttr.map(&:to_s).join("\n")
            end
          end

          x   = (0...ttr.count).to_a
          y   = x.map{|v| ttr[v] * 100}

          plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
            ds.with = 'linespoints'
            ds.title = author.capitalize
          end
        end
      end
    end
  end

  desc 'NER + POS + Stem for Turkish words using ITU NLP tools service'
  task :tag_turkish_words => :environment do
    total = BookSentence.in(:turkish).by(:akgoren).where('book_sentences.id > 2903').count
    p     = ProgressBar.create(:title => 'ITU', :starting_at => 1, :total => total,
                               :format => "%a %e %P% Tamamlanan: %c Toplam: %C")
    BookSentence.in(:turkish).by(:akgoren).where('book_sentences.id > 2903').order(:id => :asc).each_with_index do |book_sentence, idx|
      book_words      = book_sentence.book_words.sort_by{|x| x.location}
      begin
        tagged_sentence = Itu::Nlp.cts_pipeline(book_words.map(&:raw_content))
      rescue ArgumentError => e
        File.open(Rails.root.join('log/turkish-tag.log').to_s, 'a') do |f|
          f.puts "Invalid #{book_sentence.id} #{book_sentence.raw_content}"
        end
        next
      end

      if book_words.count != tagged_sentence.length
        File.open(Rails.root.join('log/turkish-tag.log').to_s, 'a') do |f|
          f.puts "Mismatch: #{book_sentence.id} #{book_words.count} != #{tagged_sentence.length}"
        end
        next
      end

      book_words.each_with_index do |word, idx|
        info = tagged_sentence[idx]

        word.pos    = info[:pos] unless info[:pos].blank?
        word.pos_v  = info[:pos_v].join('|') unless info[:pos_v].blank?
        word.entity = info[:entity] unless info[:entity].blank?
        unless info[:pos].blank? || info[:stem].blank?
          word.stem  = info[:stem]
          word.lemma = info[:pos] == 'Verb' ? info[:stem] : nil
        end
        #word.native = info[:isturkish]
        word.save!
        p.refresh
      end
      p.log "[#{idx+1}/#{total} #{total - (idx + 1)} left] #{book_sentence.id}: #{book_sentence.raw_content}"
      p.increment
    end
  end

  desc 'Stem English words using NLTK Porter Stemmer'
  task :stem_english_words => :environment do
    porter = Stemmer::Porter.new

    total = BookWord.in(:english).count
    BookWord.in(:english).order(:id => :asc).each_with_index do |book_word, idx|
      # Clean content
      content = book_word.raw_content.gsub('\\', '').gsub('*', '').gsub('’', "'").gsub('‘', "'")
      if content.include?('—')
        stem = content.split('—').map{|word|
          porter.stem(word)
        }.join('-')
      else
        stem = porter.stem(book_word.raw_content)
      end
      next if stem.blank?
      book_word.stem = stem
      book_word.save
      puts "[#{idx+1}/#{total} #{total - (idx + 1)} left] #{book_word.id}: #{book_word.raw_content} -> #{book_word.stem}"
    end
  end

  desc 'Semi-automated translation alignment'
  task :align_fix => :environment do
    source = Book.in(:english).first
    target = Book.in(:turkish).by(:akgoren).first

    source_paragraphs = source.book_parts.order(:id => :asc).map{|part| part.book_sections.order(:id => :asc).map{|section| section.book_paragraphs.order(:id => :asc)}}.flatten(3)
    target_paragraphs = target.book_parts.order(:id => :asc).map{|part| part.book_sections.order(:id => :asc).map{|section| section.book_paragraphs.order(:id => :asc)}}.flatten(3)

    idx = 0
    while idx < target_paragraphs.count
      source_p = source_paragraphs[idx]
      target_p = target_paragraphs[idx]

      break if target_p.id == 6956
      if source_p.book_sentences.count == target_p.book_sentences.count
        idx += 1
        next
      end

      source_p.book_sentences.each do |s|
        next if BookSentencesSentence.where(:source_id => s.id).count < 2

        a = BookSentencesSentence.where(:source_id => s.id).to_a
        src = "\e[01;32m#{s.id}: #{s.content}\e[00m"
        opt = Array.new
        a.each_with_index do |link,i|
          dst = BookSentence.find(link.target_id)
          opt << "\e[01;33m#{i}: #{dst.id}:#{dst.content}\e[00m"
          others = BookSentencesSentence.where(:target_id => link.target_id)
          others.reject{|x| x.source_id == s.id}.each do |other|
            os = BookSentence.find(other.source_id)
            opt << "\t\e[01;34m#{os.id}: #{os.content}\e[00m"
          end
        end

        puts src
        puts opt.join("\n")

        puts "Hizalama düzeltmesi kaldırılacak seçenekleri girin."
        l = STDIN.gets.chomp.split(' ')
        if l.blank?
          puts "Devam ediliyor."
        else
          l.map(&:to_i).each do |i|
            puts "Hizalama #{s.id} -> #{a[i].target_id} kaldırılıyor."
            ActiveRecord::Base.connection.execute("delete from book_sentences_sentences where source_id = #{s.id} and target_id = #{a[i].target_id}")
          end
        end
      end
      idx += 1
    end
  end

  desc 'Semi-automated translation alignment'
  task :align => :environment do
    source = Book.in(:english).first
    target = Book.in(:turkish).by(:akgoren).first

    source_paragraphs = source.book_parts.order(:id => :asc).map{|part| part.book_sections.order(:id => :asc).map{|section| section.book_paragraphs.order(:id => :asc)}}.flatten(3)
    target_paragraphs = target.book_parts.order(:id => :asc).map{|part| part.book_sections.order(:id => :asc).map{|section| section.book_paragraphs.order(:id => :asc)}}.flatten(3)

    idx = 0
    s_off = 0 # source offset
    t_off = 0 # target offset
    auto_process = false
    last_done_process = true
    last_done = {:source_off => nil, :target_off => nil, :target_idx => nil}
    while idx < target_paragraphs.count
      source_p = source_paragraphs[idx + s_off]
      target_p = target_paragraphs[idx + t_off]

      unless target_p.id >= 633 # 580 # 493 # 250 # 220 # 198
        idx += 1
        next
      end
      unless source_p.id >= 5230 # 5171 # 5080 # 4814 # 4778 # 4754
        s_off += 1
        next
      end
      puts '--8<--'

      if source_p.book_sentences.count == 1 && source_p.book_sentences.first.content == '>'
        s_off += 1
        next
      elsif target_p.book_sentences.count == 1 && target_p.book_sentences.first.content == '>'
        t_off += 1
        next
      elsif target_p.book_sentences.count == 1 && source_p.book_sentences.count > 1 && target_p.book_sentences.first.content.start_with?('>')
        # > 4 nisan 1984.
        t_off += 1
        next
      end

      # already processed.
      all_done = {:source => true, :target => true}
      all_done[:source] = !source_p.book_sentences.any?{|s| s.target_sentences.by(:akgoren).empty?}
      all_done[:target] = !target_p.book_sentences.any?{|s| s.source_sentences.empty?}

      if last_done_process && all_done[:source] && all_done[:target]
        last_done[:target_idx] = idx
        last_done[:source_off] = s_off
        last_done[:target_off] = t_off
        idx += 1
        next
      elsif all_done[:source]
        puts "Kaynak metin önceden hizalanmıştı."
      elsif all_done[:target]
        puts "Erek metin önceden hizalanmıştı."
      end

      # Disable auto process for short paragraphs.
      if target_p.book_sentences.count < 3
        auto_process = false
        puts "Kısa paragraf, otomatik eşleme kapatıldı."
      end

      # Probable translations form the default mapping
      # FIXME: does not work, mapping_default = Hash.new

      last_idx = 0
      source_p.book_sentences.each_with_index do |sentence,idx|
        s = ["\e[01;32m#{idx}:#{sentence.id} #{sentence.content}\e[00m"]
        #mapping_default[sentence.id] = sentence.likely_translations_in(target_p).first.andand.id
        #s << "\e[01;34m#{mapping_default[sentence.id]}\e[00m" unless mapping_default[sentence.id].nil?

        if target_p.book_sentences.length > idx
          sentence = target_p.book_sentences[idx]
          align_id = BookTranslation.where(:target_id => sentence.id).first.andand.source_id
          s << "\e[01;33m#{idx}:#{sentence.id}#{align_id.nil? ? '' : ":#{align_id}"} #{sentence.content}\e[00m"
        end
        puts s.join(' ')
        last_idx = idx
      end
      ((last_idx+1)...target_p.book_sentences.length).each do |idx|
        sentence = target_p.book_sentences[idx]
        puts "\e[01;33m#{idx}:#{sentence.id} #{sentence.content}\e[00m"
      end if target_p.book_sentences.length > (last_idx + 1)

      while true
        if auto_process && source_p.book_sentences.count == target_p.book_sentences.count
          cmd = 'a'
        else
          puts "Hizalama: hizalama için no(,no...):no(,no...), atlamak için n, birebir eşleme için a, çıkmak için ise q"
          puts "kaynak metni bir paragraf ileri/geri kaydırmak için s+/s-, ve erek metni bir paragraf ileri/geri kaydırmak için t+/t-"
          puts "kaynak metni sonraki hizalanmamış paragrafa kaydırmak için s!, erek metni sonraki hizalanmamış paragrafa kaydırmak için t!"
          puts "ileri/geri kaydırmaları sıfırlamak ve en son iki yönlü hizalaması bitmiş çifte dönmek için r"
          puts "şu an otomatik eşleme #{auto_process ? 'açık, kapatmak için' : 'kapalı, açmak için'}, komuta o ekle."
          puts "Not: Kaydırmalar otomatik eşlemeyi kapatır."
          cmd = STDIN.gets.chomp
        end

        if cmd =~ /o/i
          if auto_process
            puts "Otomatik işleme kapatılıyor"
            auto_process = false
          else
            puts "Otomatik işleme açılıyor"
            auto_process = true
          end
        end

        if cmd =~ /r/i
          if last_done[:target_idx].nil?
            puts 'Son iki yönlü hizalanmış çift bulunamadı.'
            next
          end
          s_off = last_done[:source_off]
          t_off = last_done[:target_off]
          idx   = last_done[:target_idx]
          break
        end

        last_done_process = cmd !~ /p|([st][-+])/

        if cmd =~ /s!/i
          puts "Kaynak metin bir sonraki hizalanmamış paragrafa kaydırılıyor..."
          auto_process = false
          off = 0
          source_paragraphs[(idx + s_off + 1)..-1].each do |p|
            off += 1
            break if p.book_sentences.all?{|s| BookTranslation.where(:source_id => s.id).count == 0}
          end
          puts "Kaynak metin #{off} paragraf ileri kaydırıldı."
          s_off += off
          break
        elsif cmd =~ /s\+/i
          puts "Kaynak metin bir paragraf ileri alınıyor"
          auto_process = false
          s_off += 1
          break
        elsif cmd =~ /s-/i
          puts "Kaynak metin bir paragraf geri alınıyor"
          auto_process = false
          s_off -= 1
          break
        end

        if cmd =~ /t!/i
          puts "Erek metin bir sonraki hizalanmamış paragrafa kaydırılıyor"
          auto_process = false
          off = 0
          target_paragraphs[(idx + t_off + 1)..-1].each do |p|
            off += 1
            break if p.book_sentences.all?{|s| BookTranslation.where(:target_id => s.id).count == 0}
          end
          puts "Erek metin #{off} ileri paragraf kaydırıldı."
          t_off += off
          break
        elsif cmd =~/t\+/i
          puts "Erek metin bir paragraf ileri alınıyor"
          auto_process = false
          t_off += 1
          break
        elsif cmd =~ /t-/i
          puts "Erek metin bir paragraf geri alınıyor"
          auto_process = false
          t_off -= 1
          break
        end

        if cmd =~ /n/i
          puts "Bir sonraki paragrafa geçiliyor."
          idx += 1
          break
        elsif cmd =~ /p/i
          puts "Bir önceki paragrafa dönülüyor."
          idx -= 1
          break
        elsif cmd =~ /q/i
          puts "Çıkılıyor."
          exit 0
        elsif cmd =~ /a/i
          puts "Otomatik bire-bir eşleme yapılıyor."
        elsif cmd !~ /(\d+(\s*,\s*\d+)*):(\d+(\s*,\s*\d+)*)/
          puts 'Geçersiz girdi, yeniden dene'
          next
        end

        mapping = Hash.new.tap do |h|
          cmd.scan(/(\d+(,\s*\d+)*):(\d+(\s*,\s*\d+)*)/).each do |match|
            source_ids = match[0].gsub(/\s+/, '').split(',').map(&:to_i)
            target_ids = match[2].gsub(/\s+/, '').split(',').map(&:to_i)

            if source_ids.count == 1
              src_id = source_p.book_sentences[source_ids.first].id
              h[src_id] ||= Set.new
              h[src_id] |= target_ids.map{|i| target_p.book_sentences[i].id}
            elsif target_ids.count == 1
              source_ids.each do |source_id|
                src_id = source_p.book_sentences[source_id].id
                h[src_id] ||= Set.new
                h[src_id] |= target_ids.map{|i| target_p.book_sentences[i].id}
              end
            end
          end

          (0...source_p.book_sentences.length).each do |i|
            src_id = source_p.book_sentences[i].id
            next if h.key?(src_id)
            next if target_p.book_sentences[i].nil?
            h[src_id] = Set.new([target_p.book_sentences[i].id])
          end
        end

        mapping.each do |source_id, target_ids|
          target_ids.each do |target_id|
            BookTranslation.find_or_create_by(:source_id => source_id, :target_id => target_id)
            puts "Kaynak cümle no:#{source_id}, hedef cümle no:#{target_id} ile hizalandı."
          end
        end

        idx += 1
        break
      end
    end
  end
end

