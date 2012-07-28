class AddTweetIdToTweetedWords < ActiveRecord::Migration
  def change
    add_column :tweeted_words, :tweet_id, :string
  end
end
