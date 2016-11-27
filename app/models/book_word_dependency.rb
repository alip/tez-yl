# == Schema Information
#
# Table name: book_word_dependencies
#
#  dependency :integer
#  related_id :integer
#  relater_id :integer
#
# Indexes
#
#  book_word_dependencies_index  (dependency,related_id,relater_id) UNIQUE
#

class BookWordDependency < ActiveRecord::Base
  enum :dependency => [:argument, :coordination, :conjunction,
                       :deriv, :modifier, :possessor, :punctuation,
                       :root, :subject]
  belongs_to :related_word, :class_name => 'BookWord', :foreign_key => :related_id
  belongs_to :relater_word, :class_name => 'BookWord', :foreign_key => :relater_id
end
