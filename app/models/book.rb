# == Schema Information
#
# Table name: books
#
#  id         :integer          not null, primary key
#  path       :string(255)
#  title      :string(255)
#  author     :string(255)
#  translator :string(255)
#  content    :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  language   :string(255)
#

class Book < ActiveRecord::Base
  has_many :book_parts, :dependent => :destroy

  NAMES = {:orwell  => 'George Orwell',
           :huxley  => 'Aldous Huxley',
           :uster   => 'Celâl Üster',
           :akgoren => 'Nuran Akgören',
           :tosun   => 'Ümit Tosun', # Disabled
           :walter  => 'Michael Walter'}.freeze
  AUTHORS     = NAMES.select{|k,v| %i[orwell huxley].include?(k)}.freeze
  TRANSLATORS = NAMES.reject{|k,v| %i[orwell huxley tosun].include?(k)}.freeze

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

    return {:language => :english, :author => Book::NAMES[k]} if AUTHORS.key?(k)
    return {:translator => Book::NAMES[k]} if Book::NAMES.include?(k)

    k_match = Book::NAMES.keys.detect{|kn| k.to_s =~ /#{Book::NAMES[kn]}/i}
    return {:translator => Book::NAMES[k_match]} unless k_match.nil?

    fail 'Geçersiz yazar/çevirmen adı'
  end

  scope :in, ->(language) { where(**Book.query_in(language)) }
  scope :by, -> (author_or_translator) { where(**Book.query_by(author_or_translator)) }

  # Calculate Type/Token ratio
  def ttr
    tokens = book_parts.joins(:book_sections => {:book_paragraphs => {:book_sentences => :book_words}}).count('distinct(book_words.id)')
    types  = book_parts.joins(:book_sections => {:book_paragraphs => {:book_sentences => :book_words}}).where(:book_words => {:pos => BookWord::POS.values.flatten}).count('distinct(book_words.id)')

    types.fdiv(tokens)
  end
end
