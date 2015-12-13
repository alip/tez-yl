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

  scope :in_language, -> (language) { includes(:book_sentences => [{:book_paragraph => {:book_section => {:book_part => [:book]}}}]).where(:books => {:language => language.to_s})}
  scope :with_translator, -> (translator) {
    case translator
    when /.*?(cel[aâ]l)|([üu]ster).*/i; t = 'Celâl Üster'
    when /.*?(nuran)|(akg[oö]ren).*/i;  t = 'Nuran Akgören'
    when /.*?(michael)|(walter).*/i;    t = 'Michael Walter'
    else;                               t = nil
    end
    includes(:book_sentences => [:book_paragraph => {:book_section => {:book_part => [:book]}}]).where(:books => {:translator => t}) }
end
