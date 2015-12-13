# == Schema Information
#
# Table name: book_sections
#
#  id           :integer          not null, primary key
#  book_part_id :integer
#  location     :integer
#  content      :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_book_sections_on_book_part_id  (book_part_id)
#

require 'test_helper'

class BookSectionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
