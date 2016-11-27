class AddFlagsToBookSentences < ActiveRecord::Migration
  def change
    add_column :book_sentences, :flags, :integer
  end
end
