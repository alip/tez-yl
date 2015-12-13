class RenameTableBookSentencesBookWords < ActiveRecord::Migration
  def change
    rename_table :book_sentences_book_words, :book_sentences_words
  end
end
