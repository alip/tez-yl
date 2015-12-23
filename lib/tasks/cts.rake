namespace :cts do
  desc 'Rebuild database from scratch with base data'
  task :rebuilddb => [
    'db:drop',
    'db:create',
    'db:migrate',
    'db:seed'
  ]

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

