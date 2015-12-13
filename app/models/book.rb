# == Schema Information
#
# Table name: books
#
#  id         :integer          not null, primary key
#  path       :string
#  title      :string
#  author     :string
#  translator :string
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  language   :string
#

class Book < ActiveRecord::Base
  has_many :book_parts

  scope :in_language, ->(language) { where(:language => language.to_s) }
  scope :with_translator, ->(translator) {
    case translator
    when /.*?(cel[aâ]l)|([üu]ster).*/i; t = 'Celâl Üster'
    when /.*?(nuran)|(akg[oö]ren).*/i;  t = 'Nuran Akgören'
    when /.*?(michael)|(walter).*/i;    t = 'Michael Walter'
    else;                               t = nil
    end
    where(:translator => t)
  }
end
