require 'open-uri'

class TwitterReader
  def self.geocoded_tweets(lat = 41.8883776, lng = -87.6365131, radius = 0.1, limit = 100)
    tweets = []
    
    base_uri = "https://search.twitter.com/search.json"
    query = "?geocode=#{lat},#{lng},#{radius}km&rpp=#{limit}"
    uri = base_uri + query
    
    begin
      response =  JSON.parse(open(uri).read)
    rescue
    end
    tweets << response["results"]
    
    poll = 1
    while response["next_page"] && poll < 3
      base_uri = "https://search.twitter.com/search.json"
      query = response["next_page"]
      uri = base_uri + query
      
      begin
        response =  JSON.parse(open(uri).read)
      rescue
      end
      tweets << response["results"]
      poll += 1
    end
    
    return tweets.flatten.compact
  end
end