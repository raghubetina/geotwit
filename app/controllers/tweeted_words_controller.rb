require 'open-uri'

class TweetedWordsController < ApplicationController
  # GET /tweeted_words
  # GET /tweeted_words.json
  
  def geocode(address)
    base_uri = "http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address="
    query = CGI.escape(address)
    uri = base_uri + query
    
    begin
      response = JSON.parse(open(uri).read)
      response["results"] && response["results"].first["geometry"]
      coordinates = response["results"].first["geometry"]["location"]

      lat = coordinates["lat"].to_f
      lng = coordinates["lng"].to_f
      result = []
      result << lat
      result << lng
      return result
    rescue
      return nil
    end
  end
  
  def fetch
    address = params[:address].present? ? params[:address] : "222 W Merchandise Mart Plaza, Chicago, IL"
    radius = params[:radius].present? ? params[:radius] : "50"
    latlng = geocode(address)
    lat = latlng ? latlng[0] : 41.8883776
    lng = latlng ? latlng[1] : -87.6365131
    
    TweetedWord.fetch(lat, lng, radius)
    
    redirect_to tweeted_words_url(:lat => lat, :lng => lng, :radius => radius, :address => address)
  end
  
  def index
    if address = params[:address]
      if latlng = geocode(address)
        lat = latlng[0]
        lng = latlng[1]
      end
    elsif params[:lat]
      lat = params[:lat].to_f
      lng = params[:lng].to_f
    end
    
    if lat.present? && params[:radius]
      meters_in_one_degree = Haversine.distance(lat, lng, lat + 1, lng + 1).to_m
      degrees_in_one_meter = 1 / meters_in_one_degree
      radius = params[:radius].to_f
      min_lat = lat - radius * degrees_in_one_meter
      max_lat = lat + radius * degrees_in_one_meter
      min_lng = lng - radius * degrees_in_one_meter
      max_lng = lng + radius * degrees_in_one_meter
      
      @tweeted_words = TweetedWord.where("lat BETWEEN ? AND ?", min_lat, max_lat).where("lng BETWEEN ? AND ?", min_lng, max_lng)
    else
      @tweeted_words = TweetedWord.limit(100)
    end
    
    @bins = @tweeted_words.group_by(&:word)
    @frequencies = @bins.map { |key, value| { key => value.length } }
    @frequencies_sorted = @frequencies.sort { |a, b| b.first[1] <=> a.first[1] }
    
    @frequenices_filtered = @frequencies_sorted.reject { |h| h.first[1] < 2 }
    
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
