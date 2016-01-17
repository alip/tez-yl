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

class BookSection < ActiveRecord::Base
  belongs_to :book_part
  has_many :book_paragraphs

  scope :in, -> (language) { includes(:book_part => [:book]).where(:books => Book.query_in(language)) }
  scope :by, ->(author_or_translator) { includes(:book_part => [:book]).where(:books => Book.query_by(author_or_translator)) }

  # Calculate Type/Token ratio
  def ttr
    tokens = book_paragraphs.joins(:book_sentences => :book_words).count('distinct(book_words.id)')
    types  = book_paragraphs.joins(:book_sentences => :book_words).where(:book_words => {:pos => BookWord::POS.values.flatten}).count('distinct(book_words.id)')

    types.fdiv(tokens)
  end
end
