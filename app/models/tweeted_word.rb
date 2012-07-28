class TweetedWord < ActiveRecord::Base
  attr_accessible :lat, :lon, :word, :tweet_id
end
