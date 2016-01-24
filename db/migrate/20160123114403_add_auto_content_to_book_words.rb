class AddAutoContentToBookWords < ActiveRecord::Migration
  def change
    add_column :book_words, :auto_content, :text
  end
end
