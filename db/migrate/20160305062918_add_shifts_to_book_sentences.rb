class AddShiftsToBookSentences < ActiveRecord::Migration
  def change
    add_column :book_sentences, :shifts, :integer
  end
end
