class CreateBookWordDependencies < ActiveRecord::Migration
  def change
    create_table :book_word_dependencies, :id => false do |t|
      t.integer :dependency
      t.integer :related_id, :references => 'book_words'
      t.integer :relater_id, :references => 'book_words'
    end

    add_index :book_word_dependencies, [:dependency, :related_id, :relater_id],
      :name => 'book_word_dependencies_index', :unique => true
  end
end
