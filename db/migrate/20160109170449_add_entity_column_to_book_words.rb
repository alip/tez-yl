class AddEntityColumnToBookWords < ActiveRecord::Migration
  def change
    add_column :book_words, :entity, :string
  end
end
