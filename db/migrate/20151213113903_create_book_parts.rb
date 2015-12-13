class CreateBookParts < ActiveRecord::Migration
  def change
    create_table :book_parts do |t|
      t.references :book, index: true, foreign_key: true
      t.integer :index
      t.text :content

      t.timestamps null: false
    end
  end
end
