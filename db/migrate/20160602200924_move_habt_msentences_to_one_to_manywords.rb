class MoveHabtMsentencesToOneToManywords < ActiveRecord::Migration
  def change
    count  = BookSentencesWord.count
    limit  = 10000
    offset = 0

    while offset < count
      mapping = Hash.new
      BookSentencesWord.limit(limit).offset(offset).select([:book_sentence_id, :book_word_id]).map{|x| [x[:book_sentence_id], x[:book_word_id]]}.each do |row|
        book_sentence_id, book_word_id = row
        mapping[book_sentence_id] ||= Array.new
        mapping[book_sentence_id] << book_word_id
      end
      mapping.each do |book_sentence_id, book_words|
        BookWord.where('book_sentence_id IS NULL').where(:id => book_words).update_all(:book_sentence_id => book_sentence_id)
      end

      offset += limit
      $stderr.puts offset
    end
  end
end
