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
#  raw_content     :text
#
# Indexes
#
#  index_book_paragraphs_on_book_section_id  (book_section_id)
#

class BookParagraph < ActiveRecord::Base
  belongs_to :book_section
  has_many :book_sentences

  scope :in, -> (language) { includes(:book_section => {:book_part => [:book]}).where(:books => Book.query_in(language)) }
  scope :by, ->(author_or_translator) { includes(:book_section => {:book_part => [:book]}).where(:books => Book.query_by(author_or_translator)) }
end
