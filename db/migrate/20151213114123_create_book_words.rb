class CreateBookWords < ActiveRecord::Migration
  def change
    create_table :book_words do |t|
      t.string :content
      t.string :lemma
      t.string :pos

      t.timestamps null: false
    end
  end
end
