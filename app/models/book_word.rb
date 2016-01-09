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
#  stem        :string
#

class BookWord < ActiveRecord::Base
  has_and_belongs_to_many :book_sentences

  scope :in, -> (language) { includes(:book_sentences => [{:book_paragraph => {:book_section => {:book_part => [:book]}}}]).where(:books => Book.query_in(language)) }
  scope :by, -> (author_or_translator) { includes(:book_sentences => [:book_paragraph => {:book_section => {:book_part => [:book]}}]).where(:books => Book.query_by(author_or_translator)) }

  has_many :relateds, :class_name => 'BookWordDependency', :foreign_key => :relater_id
  has_many :relaters, :class_name => 'BookWordDependency', :foreign_key => :related_id
  has_many :related_words, :through => :relateds
  has_many :relater_words, :through => :relaters
end
