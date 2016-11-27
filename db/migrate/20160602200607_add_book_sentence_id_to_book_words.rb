class AddBookSentenceIdToBookWords < ActiveRecord::Migration
  def change
    add_reference :book_words, :book_sentence, index: true, foreign_key: true
  end
end
