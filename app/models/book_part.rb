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
  has_many :book_sections

  scope :in, -> (language) { includes(:book).where(:books => Book.query_in(language)) }
  scope :by, ->(author_or_translator) { includes(:book).where(:books => Book.query_by(author_or_translator)) }

  # Calculate Type/Token ratio
  def ttr
    tokens = book_sections.joins(:book_paragraphs => {:book_sentences => :book_words}).count('distinct(book_words.id)')
    types  = book_sections.joins(:book_paragraphs => {:book_sentences => :book_words}).where(:book_words => {:pos => BookWord::POS.values.flatten}).count('distinct(book_words.id)')

    types.fdiv(tokens)
  end
end
