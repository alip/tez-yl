# == Schema Information
#
# Table name: book_parts
#
#  id         :integer          not null, primary key
#  book_id    :integer
#  location   :integer
#  content    :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_book_parts_on_book_id  (book_id)
#

class BookPart < ActiveRecord::Base
  belongs_to :book
  has_many :book_sections, :dependent => :destroy

  scope :in, -> (language) { includes(:book).where(:books => Book.query_in(language)) }
  scope :by, ->(author_or_translator) { includes(:book).where(:books => Book.query_by(author_or_translator)) }
end
