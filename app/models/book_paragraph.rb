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

  # Calculate Type/Token ratio
  def ttr
    tokens = book_sentences.joins(:book_words).count('distinct(book_words.id)')
    types  = book_sentences.joins(:book_words).where(:book_words => {:pos => BookWord::POS.values.flatten}).count('distinct(book_words.id)')

    types.fdiv(tokens)
  end

  # Output in a format suitable for alignment with hunalign.
  def to_hunalign
    String.new.tap do |s|
      s << "<p>\n" << book_sentences.order(:location => :asc).map(&:to_hunalign).join("\n")
    end
  end

  def translator
    book.translator
  end

  def book_part
    book_section.book_part
  end

  def book
    book_part.book
  end
end
