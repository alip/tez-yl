class CreateBookWordTranslations < ActiveRecord::Migration
  def change
    create_table :book_word_translations do |t|
      t.integer :source_id, :references => 'book_words'
      t.integer :target_id, :references => 'book_words'
    end

    add_index :book_word_translations, [:source_id, :target_id],
      name: 'book_word_translations_index',
      unique: true
  end
end
