# == Schema Information
#
# Table name: book_sentences
#
#  id                :integer          not null, primary key
#  book_paragraph_id :integer
#  location          :integer
#  content           :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  raw_content       :text
#
# Indexes
#
#  index_book_sentences_on_book_paragraph_id  (book_paragraph_id)
#

class BookSentence < ActiveRecord::Base
  has_and_belongs_to_many :book_words
  belongs_to :book_paragraph

  scope :in, -> (language) { includes(:book_paragraph => {:book_section => {:book_part => [:book]}}).where(:books => Book.query_in(language)) }
  scope :by, -> (author_or_translator) { includes(:book_paragraph => {:book_section => {:book_part => [:book]}}).where(:books => Book.query_by(author_or_translator)) }
  scope :in_section, -> (section_id) { includes(:book_paragraph).where(:book_section_id => section_id) }

  def source(options = {})
    options[:only] ||= nil # :content, :raw_content
    sources = BookSentencesSentence.where(:target_id => id).order(:source_id => :asc).select(:source_id).map(&:source_id)
    return nil if sources.blank?

    r = BookSentence.where(:id => sources).select(options[:only].nil? ? '*' : options[:only])
    options[:only].nil? ? r : r.map(&:"#{options[:only]}")
  end

  def pretty_location
    sprintf('%02d.%02d.%02d.%02d',
            book_part.location,
            book_section.location,
            book_paragraph.location,
            location)
  end

  def translator
    book.translator
  end

  def book_section
    book_paragraph.book_section
  end

  def book_part
    book_section.book_part
  end

  def book
    book_part.book
  end
end
