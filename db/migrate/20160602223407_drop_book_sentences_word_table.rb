class DropBookSentencesWordTable < ActiveRecord::Migration
  def change
    drop_table :book_sentences_words
  end
end
