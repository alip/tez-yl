class AddNewNamingColumnToBookWords < ActiveRecord::Migration
  def change
    add_column :book_words, :new_naming, :boolean, :default => false
  end
end
