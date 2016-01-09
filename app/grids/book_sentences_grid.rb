class BookSentencesGrid

  include Datagrid

  scope do
    BookSentence
  end

  filter(:translator, :enum,
         :header => 'Çevirmen',
         :select => Book::TRANSLATORS.values) do |name|
           by(Book::TRANSLATORS.first{|k,v| name == v}.first)
         end
  filter(:language, :enum,
         :header => 'Dil',
         :select => Book::LANGUAGES.values) do |name|
           in_language(Book::LANGUAGES.first{|k,v| name == v}.first)
         end

  column(:translator, :header => 'Çevirmen')
  column(:content, :header => 'İçerik') { |model| model.raw_content }
  column(:source, :header => 'Kaynak') { |model| model.source(:only => :raw_content).andand.join("\n") }
  column(:location, :header => 'Yer') { |model| model.pretty_location }

  def column_class(book_sentence)
    'book_sentence'
  end
end
