json.array!(@book_words) do |book_word|
  json.extract! book_word, :id, :content, :lemma, :pos
  json.url book_word_url(book_word, format: :json)
end
