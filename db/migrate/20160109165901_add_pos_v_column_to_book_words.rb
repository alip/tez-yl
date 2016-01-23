class AddPosVColumnToBookWords < ActiveRecord::Migration
  def change
    add_column :book_words, :pos_v, :string
  end
end
