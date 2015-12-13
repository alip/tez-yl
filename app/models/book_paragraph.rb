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

  scope :in_language, -> (language) { includes(:book_section => {:book_part => [:book]}).where(:books => {:language => language.to_s}) }
  scope :with_translator, -> (translator) {
    case translator
    when /.*?(cel[aâ]l)|([üu]ster).*/i; t = 'Celâl Üster'
    when /.*?(nuran)|(akg[oö]ren).*/i;  t = 'Nuran Akgören'
    when /.*?(michael)|(walter).*/i;    t = 'Michael Walter'
    else;                               t = nil
    end
    includes(:book_section => {:book_part => [:book]}).where(:books => {:translator => t}) }
end
