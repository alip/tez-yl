class CreateBookSentences < ActiveRecord::Migration
  def change
    create_table :book_sentences do |t|
      t.references :book_paragraph, index: true, foreign_key: true
      t.integer :index
      t.text :content

      t.timestamps null: false
    end
  end
end
