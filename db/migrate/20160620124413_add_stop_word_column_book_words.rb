class AddStopWordColumnBookWords < ActiveRecord::Migration
  def change
    add_column :book_words, :stop_word, :boolean, :default => false
  end
end
