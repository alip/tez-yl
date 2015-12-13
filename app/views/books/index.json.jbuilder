json.array!(@books) do |book|
  json.extract! book, :id, :path, :title, :author, :translator, :content
  json.url book_url(book, format: :json)
end
