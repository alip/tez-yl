json.array!(@book_paragraphs) do |book_paragraph|
  json.extract! book_paragraph, :id, :book_section_id, :index, :content
  json.url book_paragraph_url(book_paragraph, format: :json)
end
