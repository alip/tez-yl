class CreateBookSentencesBookSentences < ActiveRecord::Migration
  def change
    create_table :book_sentences_sentences, :id => false do |t|
      t.integer :source_id, :references => 'book_sentences'
      t.integer :target_id, :references => 'book_sentences'
    end

    add_index :book_sentences_sentences, [:source_id, :target_id],
      name: 'book_sentences_sentences_index',
      unique: true
  end
end
