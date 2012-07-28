require 'open-uri'

class TwitterReader
  def self.geocoded_tweets(lat = 41.8883776, lng = -87.6365131, radius = 0.1, limit = 100)
    all_tweets = []
    tweets = []
    
    base_uri = "https://search.twitter.com/search.json"
    query = "?geocode=#{lat},#{lng},#{radius}km&rpp=#{limit}"
    uri = base_uri + query
    
    response = open(uri).read
    
    begin
      json = JSON.parse(open(uri).read)
    rescue
      json = {}
      next_page_pos = response.index("next_page")
      radius_pos = response.index("km\",")
      json["next_page"] = response[(next_page_pos + 12)..(radius_pos + 1)]
    end
    
    tweets << json["results"]
    
    poll = 1
    while json["next_page"]
      tweets = []
      ActiveRecord::Base.logger.debug "================ Fetching next page from Twitter. ================"
      query = json["next_page"]
      uri = base_uri + query
      
      begin
        json = JSON.parse(open(uri).read)
      rescue
        json = {}
        next_page_pos = response.index("next_page")
        radius_pos = response.index("km\",")
        json["next_page"] = response[(next_page_pos + 12)..(radius_pos + 1)]
      end
      
      tweets << json["results"]
      poll += 1
      ActiveRecord::Base.logger.debug "========================================================"
      ActiveRecord::Base.logger.debug uri
    
    
      tweets = tweets.flatten.compact
    
      tweets = tweets.select { |t| t["geo"].present? }
      tweets = tweets.reject { |t| t["text"].index("RT") == 0 }
    
      tweets.each do |tweet|
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
      all_tweets << tweets
    end

    return all_tweets.flatten.compact
  end
end