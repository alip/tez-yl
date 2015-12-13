class BookSentencesGrid

  include Datagrid

  scope do
    BookSentence
  end

  filter(:id, :integer)
  filter(:translator, :string)

  column(:translator)
  column(:location) do |model|
    model.pretty_location
  end
end
