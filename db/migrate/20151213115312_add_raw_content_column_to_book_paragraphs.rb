class AddRawContentColumnToBookParagraphs < ActiveRecord::Migration
  def change
    add_column :book_paragraphs, :raw_content, :text
  end
end
