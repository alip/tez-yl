class AddLocationColumnToBookWords < ActiveRecord::Migration
  def change
    add_column :book_words, :location, :integer
  end
end
