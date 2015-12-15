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

  NAMES = {:orwell  => 'George Orwell',
           :uster   => 'Celâl Üster',
           :akgoren => 'Nuran Akgören',
           :walter  => 'Michael Walter'}.freeze
  TRANSLATORS = NAMES.reject{|k,v| k == :orwell}.freeze

  LANGUAGES = {:english => 'İngilizce',
               :german  => 'Almanca',
               :turkish => 'Türkçe'}

  def self.query_in(language)
    k = language.to_sym
    fail 'Geçersiz dil' unless Book::LANGUAGES.key?(k)

    {:language => language}
  end

  def self.query_by(author_or_translator)
    k = author_or_translator.to_sym
    fail 'Geçersiz yazar/çevirmen adı' unless Book::NAMES.key?(k)

    case k
    when :orwell
      {:language => :english, :author => Book::NAMES[k]}
    else
      {:translator => Book::NAMES[k]}
    end
  end

  scope :in, ->(language) { where(**Book.query_in(language)) }
  scope :by, -> (author_or_translator) { where(**Book.query_by(author_or_translator)) }
end
