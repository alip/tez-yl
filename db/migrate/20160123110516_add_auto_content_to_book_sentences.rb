class AddAutoContentToBookSentences < ActiveRecord::Migration
  def change
    add_column :book_sentences, :auto_content, :text
  end
end
