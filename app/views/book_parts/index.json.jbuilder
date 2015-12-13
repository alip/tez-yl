json.array!(@book_parts) do |book_part|
  json.extract! book_part, :id, :book_id, :index, :content
  json.url book_part_url(book_part, format: :json)
end
