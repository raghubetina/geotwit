class TweetedWord < ActiveRecord::Base
  attr_accessible :lat, :lng, :word, :tweet_id
  
  def self.fetch(lat, lng, radius)
    lat = lat.to_f
    lng = lng.to_f
    radius = radius.to_f/100
    
    @tweets = TwitterReader.geocoded_tweets(lat, lng, radius)
  
    @tweets = @tweets.select { |t| t["geo"].present? }
    @tweets = @tweets.reject { |t| t["text"].index("RT") == 0 }
    
    @tweets.each do |tweet|
      begin
        if TweetedWord.find_by_tweet_id(tweet["id_str"])
          next
        end
  
        text = tweet["text"]
        stripped_text = text.gsub(/:()"./, ' ')
        stripped_text.split.each do |word|
          TweetedWord.create word: word, lat: tweet["geo"]["coordinates"][0], lng: tweet["geo"]["coordinates"][1], tweet_id: tweet["id_str"]
        end
      rescue
        next
      end
    end
    return @tweets
  end
end
