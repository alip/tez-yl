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
#
# Indexes
#
#  index_book_sentences_on_book_paragraph_id  (book_paragraph_id)
#

require 'test_helper'

class BookSentenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
