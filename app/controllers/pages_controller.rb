require 'open-uri'

class PagesController < ApplicationController
  def home
    
    @tweets = TwitterReader.geocoded_tweets
  end
end

# Exclude retweets
# Do paging

