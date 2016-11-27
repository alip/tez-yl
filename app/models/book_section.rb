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

  def token_chunks
    @token_chunks ||= Array.new.tap do |chunks|
      chunk = []
      book_paragraphs.each do |book_paragraph|
        book_paragraph.book_sentences.each do |book_sentence|
          tokens = book_sentence.tokens
          if chunk.size + tokens.size > 1000
            chunks << chunk
            chunk = []
          end
          chunk += tokens
        end
      end
    end
  end

  def type_chunks
    @type_chunks ||= token_chunks.map{|chunk| chunk.select(&:type?)}
  end

  def ttr_chunks
    @ttr_chunks ||= type_chunks.each_with_index.map{|type_chunk, idx| type_chunk.count.fdiv(token_chunks[idx].count)}
  end

  def type_token_ratio
    ttr_chunks.inject(:+).fdiv(ttr_chunks.size)
  end

  # Calculate Type/Token ratio
  def tokens(unique: false, limit: nil)
    r = book_paragraphs.map(&:tokens).flatten
    unless limit.to_i > r.count
      unique ? BookWord.uniq(r, :stem => true) : r
    else
      # Pick from between
      off = (r.count - limit) / 2
      r[off...off+limit]
    end
  end

  def types(unique: false, limit: nil)
    r = tokens(:limit => limit).select(&:type?)
    unique ? BookWord.uniq(r, :stem => true) : r
  end

=begin
  def type_token_ratio(unique: false, limit: nil)
    if limit.nil?
      token_count = tokens(unique: unique).count
      token_count == 0 ? 0 : types(:unique => unique).count.fdiv(token_count)
    else
      toks = tokens(unique: unique)
      unless limit > toks.length
        off = (toks.count - limit)
        toks = toks[off...off+limit]
      end
      typs = toks.select(&:type?)
      toks.count == 0 ? 0 : typs.count.fdiv(toks.count)
    end
  end
=end

  def tt
    @tt ||= {:types  => book_paragraphs.joins(:book_sentences => :book_words).where(:book_words => {:pos => BookWord::POS.values.flatten}),
             :tokens => book_paragraphs.joins(:book_sentences => :book_words)}
  end
end
