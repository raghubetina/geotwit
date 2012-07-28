class TweetedWordsController < ApplicationController
  # GET /tweeted_words
  # GET /tweeted_words.json
  def index
    @tweeted_words = TweetedWord.all
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
