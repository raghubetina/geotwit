require 'test_helper'

class TweetedWordsControllerTest < ActionController::TestCase
  setup do
    @tweeted_word = tweeted_words(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tweeted_words)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tweeted_word" do
    assert_difference('TweetedWord.count') do
      post :create, tweeted_word: { lat: @tweeted_word.lat, lon: @tweeted_word.lon, word: @tweeted_word.word }
    end

    assert_redirected_to tweeted_word_path(assigns(:tweeted_word))
  end

  test "should show tweeted_word" do
    get :show, id: @tweeted_word
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tweeted_word
    assert_response :success
  end

  test "should update tweeted_word" do
    put :update, id: @tweeted_word, tweeted_word: { lat: @tweeted_word.lat, lon: @tweeted_word.lon, word: @tweeted_word.word }
    assert_redirected_to tweeted_word_path(assigns(:tweeted_word))
  end

  test "should destroy tweeted_word" do
    assert_difference('TweetedWord.count', -1) do
      delete :destroy, id: @tweeted_word
    end

    assert_redirected_to tweeted_words_path
  end
end
