# == Schema Information
#
# Table name: book_sections
#
#  id           :integer          not null, primary key
#  book_part_id :integer
#  location     :integer
#  content      :text(65535)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_book_sections_on_book_part_id  (book_part_id)
#

class BookSection < ActiveRecord::Base
  belongs_to :book_part
  has_many :book_paragraphs, :dependent => :destroy

  scope :in, -> (language) { includes(:book_part => [:book]).where(:books => Book.query_in(language)) }
  scope :by, ->(author_or_translator) { includes(:book_part => [:book]).where(:books => Book.query_by(author_or_translator)) }

  # Calculate Type/Token ratio
  def ttr(options = {:unique => false})
    count_arg = "distinct(book_words.#{options[:unique] ? 'content' : 'id'})"

    tokens = tt[:tokens].count
    types  = tt[:types].count(count_arg)

    types.fdiv(tokens)
  end
  def uttr; ttr(:unique => true); end

  def tt
    @tt ||= {:types  => book_paragraphs.joins(:book_sentences => :book_words).where(:book_words => {:pos => BookWord::POS.values.flatten}),
             :tokens => book_paragraphs.joins(:book_sentences => :book_words)}
  end
end
