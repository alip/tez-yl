class AddRawContentColumnToBookSentences < ActiveRecord::Migration
  def change
    add_column :book_sentences, :raw_content, :text
  end
end
