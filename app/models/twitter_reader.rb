require 'open-uri'

class TwitterReader
  def self.geocoded_tweets(lat = 41.8883776, lng = -87.6365131, radius = 0.1, limit = 100)
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
    while json["next_page"] && poll < 3
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
    end
    
    return tweets.flatten.compact
  end
end