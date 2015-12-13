class CreateBookSections < ActiveRecord::Migration
  def change
    create_table :book_sections do |t|
      t.references :book_part, index: true, foreign_key: true
      t.integer :index
      t.text :content

      t.timestamps null: false
    end
  end
end
