json.array!(@book_sentences) do |book_sentence|
  json.extract! book_sentence, :id, :book_paragraph_id, :index, :content
  json.url book_sentence_url(book_sentence, format: :json)
end
