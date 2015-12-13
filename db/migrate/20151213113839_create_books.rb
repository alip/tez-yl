class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :path
      t.string :title
      t.string :author
      t.string :translator
      t.text :content

      t.timestamps null: false
    end
  end
end
