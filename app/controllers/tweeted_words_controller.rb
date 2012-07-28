require 'open-uri'

class TweetedWordsController < ApplicationController
  # GET /tweeted_words
  # GET /tweeted_words.json
  
  def fetch
    address = params[:address]
    
    base_uri = "http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address="
    query = CGI.escape(address)
    uri = base_uri + query
    
    begin
      response = JSON.parse(open(uri).read)
    rescue
    end
    
    if response["results"] && response["results"].first["geometry"]
      coordinates = response["results"].first["geometry"]["location"]
    
      lat = coordinates["lat"]
      lon = coordinates["lng"]
    
      @tweets = TwitterReader.geocoded_tweets(lat, lon, 0.05)
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
    redirect_to tweeted_words_url(:lat => lat, :lon => lon)
  end
  
  def index
    address = params[:address]
     
    if address.present?
      base_uri = "http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address="
      query = CGI.escape(address)
      uri = base_uri + query

      begin
        response = JSON.parse(open(uri).read)
      rescue
      end

      if response["results"] && response["results"].first["geometry"]
        coordinates = response["results"].first["geometry"]["location"]

        lat = coordinates["lat"].to_f
        lon = coordinates["lng"].to_f
      end
    elsif params[:lat]
      lat = params[:lat].to_f
      lon = params[:lon].to_f
    end
    
    if lat != 0.0
      meters_in_one_degree = Haversine.distance(lat, lon, lat + 1, lon + 1).to_m
      degrees_in_one_meter = 1 / meters_in_one_degree
      radius = 50
      min_lat = lat - 50 * degrees_in_one_meter
      max_lat = lat + 50 * degrees_in_one_meter
      min_lon = lon - 50 * degrees_in_one_meter
      max_lon = lon + 50 * degrees_in_one_meter
      
      @tweeted_words = TweetedWord.where("lat BETWEEN ? AND ?", min_lat, max_lat).where("lon BETWEEN ? AND ?", min_lon, max_lon)
    else
      @tweeted_words = TweetedWord.all
    end
    @frequencies = @tweeted_words.group_by(&:word)
    @frequencies_sorted = @frequencies.sort_by { |key, value| value.count }
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tweeted_words }
    end
  end

  # GET /tweeted_words/1
  # GET /tweeted_words/1.json
  def show
    @tweeted_word = TweetedWord.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tweeted_word }
    end
  end

  # GET /tweeted_words/new
  # GET /tweeted_words/new.json
  def new
    @tweeted_word = TweetedWord.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tweeted_word }
    end
  end

  # GET /tweeted_words/1/edit
  def edit
    @tweeted_word = TweetedWord.find(params[:id])
  end

  # POST /tweeted_words
  # POST /tweeted_words.json
  def create
    @tweeted_word = TweetedWord.new(params[:tweeted_word])

    respond_to do |format|
      if @tweeted_word.save
        format.html { redirect_to @tweeted_word, notice: 'Tweeted word was successfully created.' }
        format.json { render json: @tweeted_word, status: :created, location: @tweeted_word }
      else
        format.html { render action: "new" }
        format.json { render json: @tweeted_word.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tweeted_words/1
  # PUT /tweeted_words/1.json
  def update
    @tweeted_word = TweetedWord.find(params[:id])

    respond_to do |format|
      if @tweeted_word.update_attributes(params[:tweeted_word])
        format.html { redirect_to @tweeted_word, notice: 'Tweeted word was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tweeted_word.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tweeted_words/1
  # DELETE /tweeted_words/1.json
  def destroy
    @tweeted_word = TweetedWord.find(params[:id])
    @tweeted_word.destroy

    respond_to do |format|
      format.html { redirect_to tweeted_words_url }
      format.json { head :no_content }
    end
  end
end
