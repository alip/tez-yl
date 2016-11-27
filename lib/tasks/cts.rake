namespace :cts do
  desc 'Rebuild database from scratch with base data'
  task :rebuilddb => [
    'db:drop',
    'db:create',
    'db:migrate',
    'db:seed'
  ]

  desc 'New speak mark'
  task :mark_newspeak => :environment do
    sent = BookWord.includes(:book_sentence).joins(:book_sentence).where(:book_sentences => {:language => 'english', :author => 'George Orwell'}).where('new_speak = 1 OR new_abbreviation = 1 OR new_naming = 1').to_a.flatten.uniq(&:book_sentence_id).map(&:book_sentence)
    ids  = Set.new
    sent.each_with_index do |s,i|
      trans = %i[akgoren uster walter].map{|who| s.target_sentences.by(who)}.flatten.uniq(&:id).reject{|x| ids.include?(x.id)}
      swords = s.book_words.map(&:id)
      words  = trans.map(&:book_words).flatten.map(&:id)
      ops = ''
      trans.each do |ts|
        ids << ts.id
        puts "> #{ts.translator}\t#{ts.book_words.map{|x| "#{words.index(x.id)}:#{%i[new_speak new_abbreviation new_naming].select{|t| x.send(:"#{t}?")}.join(',')}:#{x.raw_content}"}.join(' ')}\n"

        if s.book_words.map(&:clean_content).map(&:downcase).any?{|w| w.start_with?('telescreen')}
          case ts.translator
          when 'Nuran Akgören'
            tele = ts.book_words.find{|x| x.content.downcase == 'tele'}
            ekran = ts.book_words.find{|x| x.content.downcase.start_with?('ekran')}
            if tele && ekran && tele.location < ekran.location
              ops += " #{words.index(tele.id)}:#{s.book_words.map(&:clean_content).map(&:downcase).index{|w| w.start_with?('telescreen')}}"
              ops += " #{words.index(ekran.id)}:#{s.book_words.map(&:clean_content).map(&:downcase).index{|w| w.start_with?('telescreen')}}"
            end
          when 'Celâl Üster'
            teleekran = ts.book_words.find{|x| x.content.downcase =~ /tele.?ekran/i}
            if teleekran
              ops += " #{words.index(teleekran.id)}:#{s.book_words.map(&:clean_content).map(&:downcase).index{|w| w.start_with?('telescreen')}}"
            end
          when 'Michael Walter'
            teleekran = ts.book_words.find{|x| x.content.downcase == 'televisor'}
            if teleekran
              ops += " #{words.index(teleekran.id)}:#{s.book_words.map(&:clean_content).map(&:downcase).index{|w| w.start_with?('telescreen')}}"
            end
          end
        end
      end
      $stderr.puts "--- #{s.id}:Orwell\t#{s.book_words.select{|x| x.new_speak? || x.new_abbreviation? || x.new_naming?}.map{|x| "#{swords.index(x.id)}:#{x.raw_content}:#{%i[new_speak new_abbreviation new_naming].select{|t| x.send(:"#{t}?")}.join(',')}"}.join(' ')}"

      if s.book_words.select{|x| (x.new_speak? || x.new_abbreviation? || x.new_naming?) && x.content == 'telescreen'}.length == 1
        ops = ops.strip.split(' ')
        $stderr.puts "tele ekran, yapıştır"
      else
        $stderr.puts "\t#{i+1}/#{sent.count}: Söyle ne yapalım? #{ops.inspect}"
        oops = false
        ops += ' ' + STDIN.gets.chomp
        ops = ops.gsub('  ', ' ').strip.split(' ')
        next if ops.blank?
      end

      ops.each do |op|
        if op =~ /(\d+):(\d+)/
          word = words[Regexp.last_match[1].to_i]
          sword = swords[Regexp.last_match[2].to_i]
          if word.nil?
            oops = true
            $stderr.puts "HATALI EREK INDEX: #{op}"
          elsif sword.nil?
            oops = true
            $stderr.puts "HATALI KAYNAK INDEX: #{op}"
          else
            BookWordTranslation.find_or_create_by(:source_id => sword, :target_id => word)
            sw = BookWord.find(sword)
            types = %i[new_speak new_abbreviation new_naming].select{|k| sw.send(:"#{k}?")}.each do |type|
              $stderr.puts "#{words.index(word)}:#{word} -> #{sword} & #{type}"
              BookWord.where(:id => word).update_all(type => true)
            end
          end
        else
          oops = true
          $stderr.puts "HATALI KOMUT: #{op}"
        end
      end
    end
=begin
    prefix_suffixes = ['un%',
             'ante%',
             'plus%',
             'doubleplus%',
             '%wise',
    '%ed', '%ful', 'sub%']
    # Sub-Bursar -> X sub-basement X untruth (sözlükte var)
    #
    # "*goodwise", 1], ["*-wise", 1]
    # ["antegetting", 1]
    # ["constructionwise", 1]
    # ["doubleplus", 1] unproceed
    new_concepts = ['newspeak',
             'duckspeak',
             'facecrime',
             'ownlife',
             'artsem',
             'crimethink',
             'crimestop',
             'goodthink',
             'goodthinker',
             'thoughtcrime',
             'dayorder',
             'doubleplusungood',
             'unperson',
             'upsub',
             'antefiling',
             'prolefeed',
             'pornosec',
             'speakwrite',
             'unperson',
             'bellyfeel',
             'blackwhite',
             'goodsex',
             'sexcrime',
             'fullwise',
             'joycamp',
             'malreport',
             'malquote',
             'misprint',
             'oldspeak',
             'oldthink',
             'telescreen',
             'thinkpol',
             'doublethink',
             'chocorat',
             'crimethinker',
             'speedwise',
             'versificator',
      ]
    naming = [
           'airstrip one',
           'atomic war',
           'brotherhood',
           'big brother',
           'hate week',
           'inner party',
           'outer party',
           'memory hole',
           'disputed territor',
           'eastasia',
           'eurasia',
           'ffcc',
           'floating fortress',
           'golden country',
           'junior anti-sex league',
           'physical jerk',
           'reclamation centre',
           'room 101',
           'steamer',
           'two minute hate',
           'youth league',
           'malabar front',
           'chestnut tree',
           'chestnut-tree'
    ]
    abbr = {'prole' => ['proletari'],
            'ficdep' => ['fiction department', 'department of fiction'],
            'recdep' => ['record department', 'department of record'],
            'teledep' => ['teleprogram department', 'department of teleprogram'],
            'bb' => ['big brother'],
            'yp' => ['year plan'],
            'Ingsoc' => ['english socialism'],
            'minitrue' => ['ministry of truth'],
            'minipax' => ['ministry of peace'],
            'miniluv' => ['ministry of love'],
            'miniplenty' => ['ministry of plenty'],
    }
=end
  end

  desc 'Collocation preparation'
  task :prep_ngrams => :environment do
    %i[orwell akgoren uster walter].each do |who|
      File.open("#{who}-ngram.txt", "w") do |fc|
      File.open("#{who}-ngram-root.txt", "w") do |fr|
        BookSentence.includes(:book_words).by(who).where('ttr_section IS NOT NULL').order(:id).each do |sentence|
          fc.puts sentence.tokens.reject(&:stop_word?).map{|word| word.clean_content }.join(' ')
          fr.puts sentence.tokens.reject(&:stop_word?).map{|word|
            if word.verb?
              (word.lemma || word.stem || word.clean_content)
            else
              (word.stem || word.clean_content)
            end
          }.join(' ')
        end
      end
      end
    end
  end

  desc 'Walter analyze'
  task :analyze_walter => :environment do
    s = BookSentence.where(:id => [18211, 18212, 18213, 18214, 18215])
    s.each do |sent|
      wsent = sent.target_sentences.by(:walter).uniq(&:id)
      wttr  = wsent.map(&:types).flatten.count.fdiv(wsent.map(&:tokens).flatten.count)
      puts "#{sent.type_token_ratio}: #{sent.book_words.map{|x| [x.raw_content, x.pos, x.type?]}}\n#{wttr}: #{wsent.map{|s| s.book_words.map{|x| [x.raw_content, x.pos, x.type?]}}}"
    end
  end

  desc 'Calculate types for source sentences and target sentences'
  task :find_type => :environment do
    mapping = File.readlines('c-new.log').map{|line|
      _, section_idx, sentence_ids = line.split(/(\d+:\d+):/)
      [section_idx, sentence_ids.strip.split(', ').map(&:to_i)]
    }

    %i[akgoren uster walter].each do |who|
      headers = %i[section_id ttr token type non_type noun adverb adjective verb]
      #headers.concat(ActiveRecord::Base.connection.execute("select distinct pos from book_words bws join book_sentences bs on bws.book_sentence_id = bs.id where bs.language = 'English' and bs.author = 'George Orwell' order by pos;").to_a.flatten.map(&:to_sym))
      headers.concat(ActiveRecord::Base.connection.execute("select distinct pos from book_words bws join book_sentences bs on bws.book_sentence_id = bs.id where bs.author = 'George Orwell' and bs.translator = '#{Book::TRANSLATORS[who]}' order by pos;").to_a.flatten.map(&:to_sym))
      $stderr.puts who
      File.open("#{who}-type-tokens-new.csv", 'w') do |io|
        csv = CSV.new(io, :col_sep => "\t", :row_sep => "\n", :write_headers => true, :headers => headers)

        mapping.each do |section_idx, sentence_ids|
          #sentences = BookSentence.includes(:target_sentences).where(:id => sentence_ids).to_a
          sentences = BookSentence.by(who).includes(:book_words).joins(:sources).where(:book_translations => {:source_id => sentence_ids}).to_a.uniq(&:id)
          $stderr.puts "#{who}: #{section_idx}: #{sentences.count}"
          countz = sentences.each_with_object(Hash.new(0)) do |sentence, counts|
            sentence.tokens.each do |token|
              counts[:token] += 1
              if token.type?
                counts[:type] += 1
              else
                counts[:non_type] += 1
              end
              counts[token.pos.to_sym] += 1
              [:noun, :adverb, :adjective, :verb].each do |p|
                if token.send(:"#{p}?")
                  counts[p] += 1
                  break
                end
              end
            end
          end
          countz[:section_id] = section_idx
          countz[:ttr] = countz[:type].fdiv(countz[:token]).send(:*, 100).round(2)
          csv << countz.sort_by{|k,v| headers.index(k)}.map(&:last)
        end
      end
    end
  end

  desc 'Calculate TTR mapping for source sections on target sentences'
  task :find_ttr => :environment do
    mapping = {:orwell => [], :akgoren => [], :uster => [], :walter => []}
    transmp = Book::TRANSLATORS.invert
    i = 0
    limit = 1000
    BookPart.by(:orwell).where('book_parts.location IN (1,2,3,4)').each_with_index do |part, part_idx|
      part.book_sections.includes(:book_paragraphs => {:book_sentences => :book_words}).order(:id).each_with_index do |section, section_idx|
        sentences = section.book_paragraphs.map(&:book_sentences).flatten
        chunks = Hash.new.tap do |chunk_map|
          mapping.keys.each do |who|
            chunk_map[who] = []
          end

          chunk = {:orwell => [], :akgoren => [], :uster => [], :walter => []}
          sentences.each do |sentence|
            tokens = sentence.tokens
            if chunk[:orwell].size + tokens.size > limit
              chunk_map[:orwell] << chunk[:orwell]
              chunk[:orwell] = []
            end
            chunk[:orwell] += tokens
          end
          unless chunk[:orwell].empty?
            chunk_map[:orwell] << chunk[:orwell]
            chunk[:orwell] = []
          end
=begin
          File.open('cw.log', 'a') do |f|
            chunk_map[:orwell].each_with_index do |chunk, idx|
              f.puts "#{i}:#{idx}: #{chunk.map(&:book_sentence_id).flatten.uniq.join(', ')}"
            end
          end
=end

          sentence_ids = sentences.map(&:id).uniq

          #File.open('s.log', 'a') do |f|
            #f.puts("orwell:#{i+1}: #{sentence_ids.join(',')}")

            #%i(akgoren uster walter).each do |who|
            %i(walter).each do |who|
              target_sentences = BookSentence.includes(:book_words).joins(:sources).by(who).where(:book_translations => {:source_id => sentence_ids}).uniq
              target_sentences.each do |sentence|
                tokens = sentence.tokens
                if chunk[who].size + tokens.size > limit
                  chunk_map[who] << chunk[who]
                  chunk[who] = []
                end
                chunk[who] += tokens
              end
              unless chunk[who].empty?
                chunk_map[who] << chunk[who]
                chunk[who] = []
              end
              #f.puts("#{who}:#{i+1}: #{target_sentences.map(&:id).join(',')}")
            end
   #       end
        end

        #File.open('c.log', 'a') do |f|
          chunks.each do |who, chunk_list|
            #f.puts "#{who}:#{i}: #{chunk_list.flatten.map(&:book_sentence_id).flatten.uniq.join(', ')}"
            tokens = chunk_list.map(&:count)
            types  = chunk_list.map{|x| x.select(&:type?)}.map(&:count)
            ttrs   = types.each_with_index.map{|type_count, idx| type_count.fdiv(tokens[idx])}
            #ttr    = ttrs.inject(:+).fdiv(ttrs.size)
            mapping[who][i] = ttrs
          end
        #end
        i += 1
      end
    end
=begin
        tokens    = sentences.map(&:tokens).flatten.sort
        offset    = (tokens.count - limit) / 2
        ltokens   = tokens[offset...(offset+limit)]
        ltokens   += ltokens.first.book_sentence.tokens
        ltokens   += ltokens.last.book_sentence.tokens
        ltokens.uniq!
        toksent   = BookSentence.includes(:book_words).includes(:target_sentences).where(:id => ltokens.map(&:book_sentence_id).uniq).to_a
        ltypes    = ltokens.select(&:type?)
        mapping[:orwell][i] = ltypes.count.fdiv(ltokens.count)

        toksent.map(&:target_sentences).flatten.each do |target_sentence|
          t = transmp[target_sentence.translator]
          next if t.nil?
          next unless mapping.key?(t)
          mapping[t][i] ||= Array.new
          mapping[t][i] << target_sentence
        end

        $stderr.puts "This is part #{i+1}"
        File.open('s.log', 'a') do |f|
          f.puts("#{i+1}: #{toksent.map(&:id).join(',')}")
        end

        %i[akgoren uster].each do |t|
          ltokens = mapping[t][i].uniq(&:id).map(&:tokens).flatten
          ltypes  = ltokens.select(&:type?)
          mapping[t][i] = ltypes.count.fdiv(ltokens.count)
          $stderr.puts "#{t}: #{i} #{mapping[t][i]} TYPE/TOKEN=#{ltypes.count}/#{ltokens.count}"
        end
=end

    mapping.each do |who, sections|
      next unless who == :walter
      File.open("#{who}-ttr.last", 'w') do |f|
        sections.each_with_index do |ttr_chunks, section_idx|
          ttr_chunks.each_with_index do |ttr, ttr_idx|
            f.puts("#{section_idx+1}.#{ttr_idx}\t#{ttr*100}")
          end
        end
      end
    end
  end

  desc 'Tag German'
  task :tag_german => :environment do
=begin
    tagger = StanfordGerman::Tagger.new

    BookSentence.where('book_sentences.id > 41139').includes(:book_words).by(:walter).each_slice(25) do |sentences|
      $stderr.puts "#{sentences.map(&:id)}: #{sentences.map(&:raw_content).join(' ')}"
      words = sentences.map(&:book_words).flatten
      tokens = words.map(&:content)
      tagged = tagger.tag(tokens.join(' '))

      tagged.split('|').each_with_index do |tag, idx|
        pos  = tag.split('/')[1]
        word = words[idx]
        wpos = words[idx].pos_v
        word.pos_v = word.blank? ? pos : "#{wpos}|#{pos}"
        word.save!
        puts "#{word.id}: #{word.content} -> #{word.pos_v}"
      end
    end
=end

    t = `cat walter.tags`
    tags = t.split(' ').map{|x| x.split('_')}
    words = BookSentence.where('book_sentences.id > 41139').includes(:book_words).by(:walter).map(&:book_words).flatten

    w_off = 0
    oops  = 0
    i = 0
    while i < tags.count
      wi = i + w_off
      tag = tags[i]
      if words[wi].content.gsub(/[^[:alnum:]]/, '') == tag[0].gsub(/[^[:alnum:]]/, '')
         oops = 0
         npos = tag[1]
         word = words[wi]
         posv = word.pos_v.andand.split('|') || Array.new
         posv.insert(0, word.pos)
         posv = posv.uniq.join('|')
         puts "Etiketlert! #{word.id}\t#{word.content} <-> #{tag[0]}\t#{npos}/#{posv}"
         unless word.id < 582174
           word.pos = npos
           word.pos_v = posv
           word.save!
         end
      else
        puts "Sorun çıktı"
        puts "Kelime: #{words[wi].id}\t#{words[wi].content}"
        puts "Etiket: #{i}\t#{tag[0]}\t#{tag[1]}"
        puts "Ne yapayım? y -> etiketle, n -> etiketlemeden geç"
        #cmd = STDIN.gets.chomp
        cmd = 'n'
        if cmd == 'n'
          puts "Kelimeyi atlıyorum"
          oops  += 1
          if oops > 5
            puts "Atlayamadım arkadaşım nedir bu?"
            exit 1
          end
          w_off += 1
          next
        else
          puts "Ne dedin anlamadım?"
          next
        end
      end
      i += 1
    end
  end

#  desc 'Calculate STTR'
#  task :find_sttr => :environment do
#    File.open("orwell-sttr.dat", 'w') do |f|
#      BookPart.by(:orwell).includes(:book_sections => :book_paragraphs).where('book_parts.location IN (1,2,3,4)').each_with_index do |part, part_idx|
#        part.book_sections.order(:location).each_with_index do |section, section_idx|
#        end
#    end
#  end

=begin
  desc 'Calculate TTR'
  task :find_ttr => :environment do
    File.open("akgoren-ttr.dat", "w") do |f1|
    File.open("uster-ttr.dat", "w") do |f2|
      {:akgoren => f1, :uster => f2}.each do |who, ft|
        BookPart.by(who).where('book_parts.location IN (1,2,3,4)').each_with_index do |part, part_idx|
        part.book_sections.includes(:book_paragraphs => {:book_sentences => :book_words}).order(:location).each_with_index do |section, section_idx|
          sentences = section.book_paragraphs.map(&:book_sentences).flatten.reject{|x| x.tokens.count == 0 || x.types.count == 0}
          f.puts "#{part.location}.#{section.location}\t#{section.type_token_ratio(:limit => 970) * 100}\t#{section.type_token_ratio(:unique => true, :limit => 970) * 100}"
#          translation_map = BookTranslation.where(:source_id => sentences.map(&:id)).select(:target_id).distinct
#          {:akgoren => f1, :uster => f2, :walter => f3}.each do |who, ft|
#            translations = BookSentence.by(who).includes(:book_words).where(:id => translation_map)
#            tokens = translations.map(&:tokens).flatten
#            types  = tokens.select(&:type?)
#            if types.blank?
#              uttr = 0
#              sttr = 0
#            else
#              type_count = types.count
#              unique_type_count = BookWord.uniq(types, :stem => true).count
#              uttr = type_count.fdiv(tokens.count) * 100
#              sttr = unique_type_count.fdiv(tokens.count) * 100
#            end
#            ft.puts "#{part.location}.#{section.location}\t#{uttr}\t#{sttr}"
#          end
        end
      end
#    end
#    end
#    end
    end
=end



  desc 'Calculate TTR'
  task :find_orwell_ttr => :environment do
    File.open("orwell-ttr-new.dat", 'w') do |f|
#    File.open("akgoren-ttr.dat", "w") do |f1|
#    File.open("uster-ttr.dat", "w") do |f2|
#    File.open("walter-ttr.dat", "w") do |f3|
      BookPart.by(:orwell).where('book_parts.location IN (1,2,3,4)').each_with_index do |part, part_idx|
        part.book_sections.includes(:book_paragraphs => {:book_sentences => :book_words}).order(:location).each_with_index do |section, section_idx|
          sentences = section.book_paragraphs.map(&:book_sentences).flatten.reject{|x| x.tokens.count == 0 || x.types.count == 0}
          f.puts "#{part.location}.#{section.location}\t#{section.type_token_ratio(:limit => 970) * 100}\t#{section.type_token_ratio(:unique => true, :limit => 970) * 100}"
#          translation_map = BookTranslation.where(:source_id => sentences.map(&:id)).select(:target_id).distinct
#          {:akgoren => f1, :uster => f2, :walter => f3}.each do |who, ft|
#            translations = BookSentence.by(who).includes(:book_words).where(:id => translation_map)
#            tokens = translations.map(&:tokens).flatten
#            types  = tokens.select(&:type?)
#            if types.blank?
#              uttr = 0
#              sttr = 0
#            else
#              type_count = types.count
#              unique_type_count = BookWord.uniq(types, :stem => true).count
#              uttr = type_count.fdiv(tokens.count) * 100
#              sttr = unique_type_count.fdiv(tokens.count) * 100
#            end
#            ft.puts "#{part.location}.#{section.location}\t#{uttr}\t#{sttr}"
#          end
        end
      end
#    end
#    end
#    end
    end

=begin
    %i[orwell akgoren uster walter].each do |who|
      File.open("#{who}-ttr.dat", 'w') do |f|
        BookPart.by(who).includes(:book_sections => {:book_paragraphs => {:book_sentences => :book_words}}).where('book_parts.location IN (1,2,3,4)').each_with_index do |part, part_idx|
          part.book_sections.each_with_index do |section, section_idx|
            sentences = section.book_paragraphs.map(&:book_sentences).flatten.reject{|x| x.tokens.count == 0 || x.types.count == 0}
            tokens = sentences.map{|s| s.tokens.count}.inject(:+)
            types  = sentences.map{|s| s.types.count}.inject(:+)
            f.puts "#{(part_idx * 100) + section_idx}\t#{types.fdiv(tokens)}"
          end
        end
      end
    end
=end
  end

=begin
  desc 'Find splits'
  task :find_split => :environment do
    translations = Hash.new
    BookTranslation.where(:source_id => BookSentence.select(:id).by(:orwell).where('book_sentences.content RLIKE "[[:alnum:]]"')).each do |row|
      source_id = row[:source_id]
      target_id = row[:target_id]
      translations[source_id] ||= Set.new
      translations[source_id] << target_id
    end

    splits = Array.new.tap do |result|
      translations.each do |source_id,target_ids|
        scope = BookSentence.where(:id => target_ids.to_a).group(:translator).having('count(id) > 1')
        next unless scope.exists?
        sentences = scope.order(:location).to_a
        result << [source_id, sentences.first.book_part.location, sentences.map(&:id).join('|'), sentences.map(&:raw_content).join(" ")]
      end
    end.sort

    CSV.open('splits.csv', 'wb') do |csv|
      splits.each do |item|
        csv << item
      end
    end
  end

  desc 'Find additions'
  task :find_add => :environment do
    require 'csv'

    translations = Hash.new
    BookTranslation.where(:source_id => BookSentence.select(:id).by(:orwell).where('book_sentences.content RLIKE "[[:alnum:]]"')).each do |row|
      source_id = row[:source_id]
      target_id = row[:target_id]
      translations[source_id] ||= Set.new
      translations[source_id] << target_id
    end

    subtractions = Array.new.tap do |result|
      translations.select{|source_id,target_ids| target_ids.count < Book::TRANSLATORS.count}.each do |source_id, target_ids|
        translators  = BookSentence.where(:id => target_ids.to_a).pluck(:translator)
        missing_translators = Book::TRANSLATORS.reject{|translator_id, translator_name| translators.include?(translator_name)}

        missing_translators.each do |translator_id, translator_name|
          sentence = BookSentence.includes(:book_paragraph => {:book_section => :book_part}).find(source_id)
          #paragraph = sentence.book_paragraph.book_sentences.to_a.map(&:target_sentences).map(&:to_a).flatten.select{|ts| ts.translator == translator_name}.sort_by(&:location).map(&:raw_content).join(' ')
          result << [translator_id, sentence.book_part.location, source_id, sentence.raw_content] #paragraph]
        end
      end
    end.sort

    CSV.open('subtractions.csv', 'wb') do |csv|
      subtractions.each do |item|
        csv << item
      end
    end
  end
=end

  desc 'Find subtractions'
  task :find_sub => :environment do
    require 'csv'

    translations = Hash.new
    BookTranslation.where(:source_id => BookSentence.select(:id).by(:orwell).where('book_sentences.content RLIKE "[[:alnum:]]"')).each do |row|
      source_id = row[:source_id]
      target_id = row[:target_id]
      translations[source_id] ||= Set.new
      translations[source_id] << target_id
    end

    subtractions = Array.new.tap do |result|
      translations.select{|source_id,target_ids| target_ids.count < Book::TRANSLATORS.count}.each do |source_id, target_ids|
        translators  = BookSentence.where(:id => target_ids.to_a).pluck(:translator)
        missing_translators = Book::TRANSLATORS.reject{|translator_id, translator_name| translators.include?(translator_name)}

        missing_translators.each do |translator_id, translator_name|
          sentence = BookSentence.includes(:book_paragraph => {:book_section => :book_part}).find(source_id)
          #paragraph = sentence.book_paragraph.book_sentences.to_a.map(&:target_sentences).map(&:to_a).flatten.select{|ts| ts.translator == translator_name}.sort_by(&:location).map(&:raw_content).join(' ')
          result << [translator_id, sentence.book_part.location, source_id, sentence.raw_content] #paragraph]
        end
      end
    end.sort

    CSV.open('subtractions.csv', 'wb') do |csv|
      subtractions.each do |item|
        csv << item
      end
    end
  end

  desc 'Parse German'
  task :parse_german => :environment do
    File.open('mismatch.log', 'w') do |f|
      bs = BookSentence.by(:walter).order('book_sentences.id ASC').where('book_sentences.id > 41610').select(:id)
      bs.each_with_index do |tid, idx|
        ts = BookSentence.includes(:book_words).find(tid)
        wd = ts.book_words.order(:location)
        ct = wd.map(&:content).join(' ')
        gs = GermanParser::Parser.new
        p  = gs.parse(ct)
        gs.close
        if p.count != wd.count
          f.puts("#{ts.id}: #{wd.count} #{p.count}")
          next
        end
        p.each_with_index do |info, idx|
          word = wd[idx]
          word.pos = info[:pos]
          word.pos_v = info[:pos_v]
          word.lemma = info[:lemma] if word.pos.start_with?('V')
          word.stem  = info[:lemma]
          if info[:lemma] == 'zimmer' && word.content == 'gesprochen'
            byebug
          end
          word.save!
        end
        $stderr.puts("#{idx}: #{ts.id}: #{ct}")
      end
    end
  end

  desc 'Mark shifts'
  task :mark_shifts => :environment do
    c = 0
    t = BookSentence.by(:uster).count
    t += BookSentence.by(:akgoren).count
    %i[uster akgoren].each do |tx|
      BookSentence.by(tx).includes(:source_sentences).each do |ts|
        c += 1
        puts ">>> #{c}/#{t} (#{t - c} left)"
        if ts.flag_set?(:passive) && !ts.source_sentences.any?{|s| s.flag_set?(:passive)}
          ts.shifts |= (1 << BookSentence::SHIFTS.index(:passivisation))
        else
          ts.shifts &= ~(1 << BookSentence::SHIFTS.index(:passivisation))
        end
        if ts.flag_set?(:passive) && !ts.source_sentences.any?{|s| s.flag_set?(:passive)}
          ts.shifts |= (1 << BookSentence::SHIFTS.index(:depassivisation))
        else
          ts.shifts &= ~(1 << BookSentence::SHIFTS.index(:depassivisation))
        end
        if ts.flag_set?(:personal_pronoun) && !ts.source_sentences.any?{|s| s.flag_set?(:personal_pronoun)}
          ts.shifts |= (1 << BookSentence::SHIFTS.index(:pronominalisation))
        else
          ts.shifts &= ~(1 << BookSentence::SHIFTS.index(:pronominalisation))
        end
        if !ts.flag_set?(:personal_pronoun) && ts.source_sentences.any?{|s| s.flag_set?(:personal_pronoun)}
          ts.shifts |= (1 << BookSentence::SHIFTS.index(:depronominalisation))
        else
          ts.shifts &= ~(1 << BookSentence::SHIFTS.index(:depronominalisation))
        end
        if ts.flag_set?(:exclamation) && !ts.source_sentences.any?{|s| s.flag_set?(:exclamation)}
          ts.shifts |= (1 << BookSentence::SHIFTS.index(:exclamation))
        else
          ts.shifts &= ~(1 << BookSentence::SHIFTS.index(:exclamation))
        end
        if !ts.flag_set?(:exclamation) && ts.source_sentences.any?{|s| s.flag_set?(:exclamation)}
          ts.shifts |= (1 << BookSentence::SHIFTS.index(:deexclamation))
        else
          ts.shifts &= ~(1 << BookSentence::SHIFTS.index(:deexclamation))
        end
        if ts.flag_set?(:question) && !ts.source_sentences.any?{|s| s.flag_set?(:question)}
          ts.shifts |= (1 << BookSentence::SHIFTS.index(:questionation))
        else
          ts.shifts &= ~(1 << BookSentence::SHIFTS.index(:questionation))
        end
        if !ts.flag_set?(:question) && ts.source_sentences.any?{|s| s.flag_set?(:question)}
          ts.shifts |= (1 << BookSentence::SHIFTS.index(:dequestionation))
        else
          ts.shifts &= ~(1 << BookSentence::SHIFTS.index(:dequestionation))
        end
        ts.save!
      end
    end
  end

  desc 'Merge incorrectly tokenized sentences'
  task :merge_sentences => :environment do
    stop = %w[… . ? ! :]
    smap = []
    cmap = []
    #(47400..47734).each do |sid|
    #  s = BookSentence.find(sid) rescue nil
      #next if s.nil?
    BookSentence.by(:walter).order(:id => :asc).each do |s|
      next if cmap.blank? && stop.any?{|x| s.raw_content.end_with?(x)}
      break if s.id >= 47400
      next unless s.id > 41005

      cmap << s
      if stop.any?{|x| s.raw_content.end_with?(x)}
        smap << cmap
        cmap = []
      end
    end

    smap.each do |cmap|
      next unless cmap.map(&:source_sentences).flatten.map(&:id).uniq.length == 1
      cmap.each do |sent|
        puts "\t#{sent.id} #{sent.raw_content}"
      end
      print ">>> Merge #{cmap.count} sentences? (y/n) "
      next unless true # STDIN.gets.chomp =~ /y/i

      BookSentence.merge!(*cmap.map(&:id))
      puts ">>> Merged #{cmap.count} sentences"
    end
  end

  desc 'Apply heuristic align'
  task :apply_heuristic => :environment do
    mx = BookSentence.by(:akgoren).joins(:sources).select(:id).to_a.map(&:id)
    tx = BookSentence.by(:akgoren).where.not(:id => mx)

    tx.each do |t|
      before = BookSentence.by(:akgoren).joins(:sources).where(['book_sentences.id < ?', t.id]).order(:id => :desc).first
      after  = BookSentence.by(:akgoren).joins(:sources).where(['book_sentences.id > ?', t.id]).order(:id => :desc).first

      before_paragraph = before.source_sentences.order(:id).first.book_paragraph_id
      after_paragraph  = after.source_sentences.order(:id => :desc).first.book_paragraph_id

      sources = BookSentence.by(:orwell).includes(:target_sentences).where(['book_paragraph_id >= ? and book_paragraph_id <= ?', before_paragraph, after_paragraph])

      # trx = t.auto_content.split(/\b/).map(&:strip).reject(&:blank?).reject{|x| x !~ /\w/}.map(&:downcase).join(' ')
      srx = sources.sort_by{|x|
        content = x.auto_content.split(/\b/).map(&:strip).reject(&:blank?).reject{|x| x !~ /\w/}.map(&:downcase).join(' ')
        targets = [t]
        unless x.target_sentences.blank?
          targets |= x.target_sentences
        end
        targets.sort_by!(&:id)
        target_content = targets.map{|tx| tx.content.andand.split(/\b/).andand.map(&:strip).andand.reject(&:blank?).andand.reject{|x| x !~ /\w/}.andand.map(&:downcase)}.flatten.compact.join(' ')

        content.ld(target_content)
      }.take(3)
      byebug
    end
  end

  desc 'Check and apply bleualign generated alignments'
  task :apply_bleualign => :environment do
    src = Rails.root.join('bleu/orwell-de-appendix-align-s').to_s
    dst = Rails.root.join('bleu/orwell-de-appendix-align-t').to_s

    Hash.new.tap do |h|
      ss = File.readlines(src).map(&:strip)
      ts = File.readlines(dst).map(&:strip)

      ss.each_with_index do |rs, idx|
        sid = rs.split(/(?<!\d)\. /).map{|rt| rt = rt.truncate(30).gsub('\\', '_').sub(/\.\.\.\Z/,'') + '%'; BookSentence.where(['raw_content LIKE ?', rt]).select(:id).first.id rescue nil}
        tid = ts[idx].split(/(?<!\d)\. /).map{|rt| rt = rt.truncate(30).gsub('\\', '_').sub(/\.\.\.\Z/,'') + '%'; BookSentence.where(['raw_content LIKE ?', rt]).select(:id).first.id rescue nil}

        sid.compact.each do |ssid|
          h[ssid] ||= Array.new
          h[ssid] |= tid.compact
        end
      end
    end.each do |k,v|
      #next unless k >= 18708
      #next unless v.sort.reverse.first >= 3791
      s = BookSentence.find(k)
      t = v.map{|tid| BookSentence.find(tid)}
      #next unless s.targets.blank?
      #next unless s.sources.blank?

      t.each do |tt|
        next unless tt.book_paragraph.book_section_id == 180
        puts "\e[01;32m#{s.id}: #{s.content}\e[00m\e[01;33m\n#{tt.id}: #{tt.raw_content}\e[00m"
        cmd = 'e'
        if cmd =~ /h/i
          next
        elsif cmd =~ /e/i || cmd.blank?
          BookTranslation.find_or_create_by(:source_id => s.id, :target_id => tt.id)
          puts "Kaynak cümle no:#{s.id}, hedef cümle no:#{tt.id} ile hizalandı."
        end
      end
    end
  end

  desc 'Prepare bleualign inputs for walter appendix'
  task :prepare_bleualign_walter => :environment do
    %i[orwell walter].each do |author|
      text = Rails.root.join("bleu/1984-appendix-window3-#{author}.#{author == :orwell ? 'en' : 'de'}").to_s
      auto = "#{text}.auto"
      imap = "#{text}.map"

      ftext = File.open(text, 'w')
      fauto = File.open(auto, 'w')
      fimap = File.open(imap, 'w')
      begin
        BookSection.by(author).order(:id => :asc).includes(:book_paragraphs => :book_sentences).each do |book_section|
          case author
          when :orwell
            next unless book_section.id == 72
          when :walter
            next unless book_section.id == 180
          end
          book_section.book_paragraphs.order(:id => :asc).each do |book_paragraph|
            #case author
            #when :orwell
              #next unless book_paragraph.id >= 5657 # 5608 # 5591 # 5516
              #next unless book_paragraph.book_sentences.includes(:target_sentences).any?{|s| s.target_sentences.by(:akgoren).empty?}
            #when :akgoren
              #next unless book_paragraph.id >= 1017 # 967 # 950 # 874
              #next unless book_paragraph.book_sentences.any?{|s| s.source_sentences.empty?}
            #end
            book_paragraph.book_sentences.order(:id => :asc).select([:id, :raw_content, :auto_content]).each do |book_sentence|
              clean_content = book_sentence.raw_content.gsub(/[^[:alpha:] ]/, '').gsub(/\s+/, ' ').sub(/^ /, '').sub(/\s$/, '').downcase
              ftext.puts clean_content
              fimap.puts "#{book_sentence.id.to_s}|#{clean_content}"

              auto_content = nil
              case author
              when :orwell
                unless book_sentence.target_sentences.empty?
                  auto_content = book_sentence.target_sentences.map(&:raw_content).join(' ')
                end
              when :walter
                unless book_sentence.source_sentences.empty?
                  auto_content = book_sentence.source_sentences.map(&:raw_content).join(' ')
                end
              end
              if auto_content.nil?
                auto_content = book_sentence.auto_content
              end

              fauto.puts auto_content.gsub(/[^[:alpha:] ]/, '').gsub(/\s+/, ' ').sub(/^ /, '').sub(/\s$/, '').downcase
              $stderr.print '.'
            end
          end
          ftext.puts '.EOA'
          fauto.puts '.EOA'
        end
      ensure
        fimap.close
        ftext.close
        fauto.close
      end
    end
  end

  desc 'Prepare bleualign inputs'
  task :prepare_bleualign => :environment do
    %i[orwell akgoren].each do |author|
      text = Rails.root.join("bleu/1984-window3-#{author}.#{author == :orwell ? 'en' : 'tr'}").to_s
      auto = "#{text}.auto"
      imap = "#{text}.map"

      ftext = File.open(text, 'w')
      fauto = File.open(auto, 'w')
      fimap = File.open(imap, 'w')
      begin
        BookSection.by(author).order(:id => :asc).includes(:book_paragraphs => :book_sentences).each do |book_section|
          book_section.book_paragraphs.order(:id => :asc).each do |book_paragraph|
            case author
            when :orwell
              next unless book_paragraph.id >= 5657 # 5608 # 5591 # 5516
              #next unless book_paragraph.book_sentences.includes(:target_sentences).any?{|s| s.target_sentences.by(:akgoren).empty?}
            when :akgoren
              next unless book_paragraph.id >= 1017 # 967 # 950 # 874
              #next unless book_paragraph.book_sentences.any?{|s| s.source_sentences.empty?}
            end
            book_paragraph.book_sentences.order(:id => :asc).select([:id, :raw_content, :auto_content]).each do |book_sentence|
              clean_content = book_sentence.raw_content.gsub(/[^[:alpha:] ]/, '').gsub(/\s+/, ' ').sub(/^ /, '').sub(/\s$/, '').downcase
              ftext.puts clean_content
              fimap.puts "#{book_sentence.id.to_s}|#{clean_content}"

              auto_content = nil
              case author
              when :orwell
                unless book_sentence.target_sentences.empty?
                  auto_content = book_sentence.target_sentences.map(&:raw_content).join(' ')
                end
              when :akgoren
                unless book_sentence.source_sentences.empty?
                  auto_content = book_sentence.source_sentences.map(&:raw_content).join(' ')
                end
              end
              if auto_content.nil?
                auto_content = book_sentence.auto_content
              end

              fauto.puts auto_content.gsub(/[^[:alpha:] ]/, '').gsub(/\s+/, ' ').sub(/^ /, '').sub(/\s$/, '').downcase
              $stderr.print '.'
            end
          end
          ftext.puts '.EOA'
          fauto.puts '.EOA'
        end
      ensure
        fimap.close
        ftext.close
        fauto.close
      end
    end
  end

  desc 'Verify hunalign alignments'
  task :check_hunalign => :environment do
    data = File.readlines('/tmp/align.text').map{|s| data = s.strip.split("\t") ; {:confidence => data[-1].to_f, :source => data[1].split(' ~~~ '), :target => data[0].split(' ~~~ ')}}
    source_offset = 0
    target_offset = 0

    data.each do |item|
      item[:target].each_with_index do |ts, idx|
        ssdb = BookSentence.by(:orwell).limit(1).offset(source_offset + idx).first
        tsid = BookSentence.by(:uster).limit(1).offset(target_offset + idx).select(:id).first.id

        if ssdb.targets.map(&:target_id).include?(tsid)
          puts "#{ssdb.id} <-> #{tsid} OK (confidence: #{item[:confidence]})"
        else
          puts "#{ssdb.id} <-> #{tsid} NOT OK (confidence: #{item[:confidence]})"
        end
      end
      source_offset += item[:source].length
      target_offset += item[:target].length
    end
  end

  desc 'Write hunalign stem files'
  task :prep_hunalign => :environment do
    %i[orwell uster akgoren].each do |author|
      path = Rails.root.join("align/1984-#{author}.stem").to_s
      unless File.exist?(path)
        File.open(path, 'w') do |f|
          BookParagraph.by(author).order(:id => :asc).includes(:book_sentences => :book_words).each do |p|
            $stderr.puts p.id
            f.puts p.to_hunalign
          end
        end
      end

      path = Rails.root.join("align/1984-#{author}.raw").to_s
      unless File.exist?(path)
        File.open(path, 'w') do |f|
          BookSentence.by(author).order(:id => :asc).select(:raw_content).each do |s|
            f.puts s.raw_content
          end
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

    # Prepare hunalign data for calibration.
    hunalign_raw = File.readlines(Rails.root.join('align/akgoren-align.text').to_s).map{|s| data = s.strip.split("\t") ; {:confidence => data[-1].to_f, :source => data[1].split(' ~~~ '), :target => data[0].split(' ~~~ ')}}
    hunalign = Hash.new.tap do |h|
      sids = BookSentence.by(:orwell).order(:id => :asc).select(:id).map(&:id)
      tids = BookSentence.by(:akgoren).order(:id => :asc).select(:id).map(&:id)

      source_offset = 0
      target_offset = 0

      hunalign_raw.each do |item|
        item[:target].each_with_index do |ts, idx|
          tsid = tids[target_offset + idx]

          item[:source].each_with_index do |ss, ss_idx|
            ssid = sids[source_offset + ss_idx]
            h[ssid] ||= Array.new
            h[ssid] << tsid
          end
        end
        source_offset += item[:source].length
        target_offset += item[:target].length
      end
    end

    idx = 0
    s_off = 0 # source offset
    t_off = 0 # target offset
    auto_process = false
    last_done_process = true
    last_done = {:source_off => nil, :target_off => nil, :target_idx => nil}
    while idx < target_paragraphs.count
      source_p = source_paragraphs[idx + s_off]
      target_p = target_paragraphs[idx + t_off]

      if source_p.id == 5973
        source_idx = source_paragraphs.index{|sp| sp.id == 5948}
        s_off = source_idx - idx
        next
      end

      unless target_p.id >= 1306 # 764 # 762 # 633 # 580 # 493 # 250 # 220 # 198
        idx += 1
        next
      end
      unless source_p.id >= 5948 # 5366 # 5364 # 5230 # 5171 # 5080 # 4814 # 4778 # 4754
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
      auto_process = false # past bleualign

      # Probable translations form the default mapping
      # FIXME: does not work, mapping_default = Hash.new

      last_idx = 0
      source_p.book_sentences.each_with_index do |sentence,idx|
        s = ["\e[01;32m#{idx}:#{sentence.id} #{sentence.content}#{hunalign[sentence.id].blank? ? '' : " h#{hunalign[sentence.id].sort.join(',')}"}\e[00m"]
        #mapping_default[sentence.id] = sentence.likely_translations_in(target_p).first.andand.id
        #s << "\e[01;34m#{mapping_default[sentence.id]}\e[00m" unless mapping_default[sentence.id].nil?

        if target_p.book_sentences.length > idx
          sentence = target_p.book_sentences[idx]
          align_id = BookTranslation.where(:target_id => sentence.id).first.andand.source_id
          if align_id.nil?
            s << "\e[01;33m#{idx}:#{sentence.id}#{align_id.nil? ? '' : ":#{align_id}"} #{sentence.content}\e[00m"
          else
            s << "\e[01;35m#{idx}:#{sentence.id}#{align_id.nil? ? '' : ":#{align_id}"} #{sentence.content}\e[00m"
          end
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
          puts "Hizalama: hizalama için no(,no...):no(,no...), atlamak için n, birebir eşleme için a, hunalign eşleme için h, çıkmak için ise q"
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
              src_id = source_p.book_sentences[source_ids.first].id rescue nil
              if src_id.nil?
                src_id = source_ids.first
              end
              h[src_id] ||= Set.new
              h[src_id] |= target_ids.map{|i| x = target_p.book_sentences[i].id rescue nil; x.nil? ? i : x}
            elsif target_ids.count == 1
              source_ids.each do |source_id|
                src_id = source_p.book_sentences[source_id].id
                h[src_id] ||= Set.new
                h[src_id] |= target_ids.map{|i| target_p.book_sentences[i].id}
              end
            end
          end

=begin
          (0...source_p.book_sentences.length).each do |i|
            src_id = source_p.book_sentences[i].id
            next if h.key?(src_id)
            next if target_p.book_sentences[i].nil?
            h[src_id] = Set.new([target_p.book_sentences[i].id])
          end
=end
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
