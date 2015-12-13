class CreateBookSentencesBookWords < ActiveRecord::Migration
  def change
    create_table :book_sentences_book_words, :id => false do |t|
      t.references :book_sentence, :book_word
    end

    add_index :book_sentences_book_words, [:book_sentence_id, :book_word_id],
      name: "book_sentences_book_words_index",
      unique: true
  end
end
