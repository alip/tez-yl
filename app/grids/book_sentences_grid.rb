class BookSentencesGrid

  include Datagrid

  scope do
    BookSentence
  end

  filter(:translator, :enum,
         :header => 'Çevirmen',
         :select => ['Celâl Üster', 'Nuran Akgören', 'Michael Walter']) { |value| with_translator(value) }
  filter(:language, :enum,
         :header => 'Dil',
         :select => ['İngilizce', 'Almanca', 'Türkçe']) do |value|
    case value
    when 'İngilizce';   in_language(:english)
    when 'Almanca';     in_language(:german)
    when 'Türkçe';      in_language(:turkish)
    end
  end

  column(:translator, :header => 'Çevirmen')
  column(:location, :header => 'Yer') { |model| model.pretty_location }
  column(:content, :header => 'İçerik') { |model| model.raw_content.truncate(80) }
end
