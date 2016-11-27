class AddNewSpeakColumnToBookWords < ActiveRecord::Migration
  def change
    add_column :book_words, :new_speak, :boolean, :default => false
  end
end
