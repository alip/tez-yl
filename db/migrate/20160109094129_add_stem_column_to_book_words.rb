class AddStemColumnToBookWords < ActiveRecord::Migration
  def change
    add_column :book_words, :stem, :string
  end
end
