class BookSentence < ActiveRecord::Base
  belongs_to :book_paragraph
end
