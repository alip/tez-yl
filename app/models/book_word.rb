# == Schema Information
#
# Table name: book_words
#
#  id         :integer          not null, primary key
#  content    :string
#  lemma      :string
#  pos        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BookWord < ActiveRecord::Base
  has_and_belongs_to_many :book_sentences
end
