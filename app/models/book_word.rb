# == Schema Information
#
# Table name: book_words
#
#  id          :integer          not null, primary key
#  content     :string
#  lemma       :string
#  pos         :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  raw_content :text
#  location    :integer
#

class BookWord < ActiveRecord::Base
  has_and_belongs_to_many :book_sentences

  scope :in, -> (language) { includes(:book_sentences => [{:book_paragraph => {:book_section => {:book_part => [:book]}}}]).where(:books => Book.query_in(language)) }
  scope :by, -> (author_or_translator) { includes(:book_sentences => [:book_paragraph => {:book_section => {:book_part => [:book]}}]).where(:books => Book.query_by(author_or_translator)) }
end
