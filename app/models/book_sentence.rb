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

  scope :in_section, -> (section_id) { includes(:book_paragraph).where(:book_section_id => section_id) }
  scope :in_language, -> (language) { includes(:book_paragraph => {:book_section => {:book_part => [:book]}}).where(:books => {:language => language.to_s}) }
  scope :with_translator, -> (translator) {
    case translator
    when /.*?(cel[aâ]l)|([üu]ster).*/i; t = 'Celâl Üster'
    when /.*?(nuran)|(akg[oö]ren).*/i;  t = 'Nuran Akgören'
    when /.*?(michael)|(walter).*/i;    t = 'Michael Walter'
    else;                               t = nil
    end
    includes(:book_paragraph => {:book_section => {:book_part => [:book]}}).where(:books => {:translator => t}) }

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
