class AddRawContentColumnToBookWords < ActiveRecord::Migration
  def change
    add_column :book_words, :raw_content, :text
  end
end
