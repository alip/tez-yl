json.array!(@book_sections) do |book_section|
  json.extract! book_section, :id, :book_part_id, :index, :content
  json.url book_section_url(book_section, format: :json)
end
