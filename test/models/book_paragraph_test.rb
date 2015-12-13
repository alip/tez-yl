# == Schema Information
#
# Table name: book_paragraphs
#
#  id              :integer          not null, primary key
#  book_section_id :integer
#  location        :integer
#  content         :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_book_paragraphs_on_book_section_id  (book_section_id)
#

require 'test_helper'

class BookParagraphTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
