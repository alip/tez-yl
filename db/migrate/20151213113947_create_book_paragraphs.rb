class CreateBookParagraphs < ActiveRecord::Migration
  def change
    create_table :book_paragraphs do |t|
      t.references :book_section, index: true, foreign_key: true
      t.integer :index
      t.text :content

      t.timestamps null: false
    end
  end
end
