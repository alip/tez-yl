class RenameIndexColumnsToLocation < ActiveRecord::Migration
  def change
    rename_column :book_parts, :index, :location
    rename_column :book_sections, :index, :location
    rename_column :book_paragraphs, :index, :location
    rename_column :book_sentences, :index, :location
  end
end
