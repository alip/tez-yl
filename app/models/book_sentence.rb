# == Schema Information
#
# Table name: book_sentences
#
#  id                :integer          not null, primary key
#  book_paragraph_id :integer
#  location          :integer
#  content           :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  raw_content       :text
#
# Indexes
#
#  index_book_sentences_on_book_paragraph_id  (book_paragraph_id)
#

class BookSentence < ActiveRecord::Base
  has_and_belongs_to_many :book_words
  belongs_to :book_paragraph
end
