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

  scope :in_language, -> (language) { includes(:book).where(:books => {:language => language.to_s}) }
  scope :with_translator, -> (translator) {
    case translator
    when /.*?(cel[aâ]l)|([üu]ster).*/i; t = 'Celâl Üster'
    when /.*?(nuran)|(akg[oö]ren).*/i;  t = 'Nuran Akgören'
    when /.*?(michael)|(walter).*/i;    t = 'Michael Walter'
    else;                               t = nil
    end
    includes(:book).where(:books => {:translator => t}) }
end
