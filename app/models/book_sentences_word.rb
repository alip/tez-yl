class BookSentencesWord < ActiveRecord::Base
  belongs_to :book_sentence
  belongs_to :book_word
end
