class CreateTweetedWords < ActiveRecord::Migration
  def change
    create_table :tweeted_words do |t|
      t.string :word
      t.float :lat
      t.float :lon

      t.timestamps
    end
  end
end
