require 'open-uri'

class PagesController < ApplicationController
  def home
    lat = 41.8883776
    lon = -87.6365131
    @tweets = TwitterReader.geocoded_tweets(lat, lon)
    @tweets = @tweets.select { |t| t["geo"].present? }
    @tweets = @tweets.reject { |t| t["text"].index("RT") == 0 }
    
    @tweets.each do |tweet|
      
      if TweetedWord.find_by_tweet_id(tweet["id_str"])
        next
      end
      
      text = tweet["text"]
      logger.debug text + " ============== TEXT ======================="
      
      stripped_text = text.gsub(/:()"./, ' ')
      logger.debug stripped_text + " ================ STRIPPED TEXT====================="
      
      stripped_text.split.each do |word|
        logger.debug word + " =============== WORD ======================"
        TweetedWord.create word: word, lat: tweet["geo"]["coordinates"][0], lon: tweet["geo"]["coordinates"][1], tweet_id: tweet["id_str"]
      end
    end
  end
end

# Exclude retweets
# Do paging

