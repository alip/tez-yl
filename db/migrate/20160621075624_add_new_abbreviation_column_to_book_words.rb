class AddNewAbbreviationColumnToBookWords < ActiveRecord::Migration
  def change
    add_column :book_words, :new_abbreviation, :boolean, :default => false
  end
end
