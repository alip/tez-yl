# == Schema Information
#
# Table name: book_parts
#
#  id         :integer          not null, primary key
#  book_id    :integer
#  index      :integer
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_book_parts_on_book_id  (book_id)
#

require 'test_helper'

class BookPartTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
