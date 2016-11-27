class AddAuthorToBookSentences < ActiveRecord::Migration
  def change
    add_column :book_sentences, :author, :string
  end
end
