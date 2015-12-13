# == Schema Information
#
# Table name: book_parts
#
#  id         :integer          not null, primary key
#  book_id    :integer
#  location   :integer
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_book_parts_on_book_id  (book_id)
#

class BookPart < ActiveRecord::Base
  belongs_to :book
end
