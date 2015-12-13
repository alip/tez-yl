# == Schema Information
#
# Table name: book_sections
#
#  id           :integer          not null, primary key
#  book_part_id :integer
#  index        :integer
#  content      :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_book_sections_on_book_part_id  (book_part_id)
#

class BookSection < ActiveRecord::Base
  belongs_to :book_part
end
