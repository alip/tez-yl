class AddNativeColumnToBookWords < ActiveRecord::Migration
  def change
    add_column :book_words, :native, :boolean
  end
end
