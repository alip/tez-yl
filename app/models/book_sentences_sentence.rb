class BookSentencesSentence < ActiveRecord::Base
  has_one :source, :class_name => 'BookSentence'
  has_one :target, :class_name => 'BookSentence'
end
