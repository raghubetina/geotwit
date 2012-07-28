class RenameLonToLng < ActiveRecord::Migration
  def up
    rename_column :tweeted_words, :lon, :lng
  end

  def down
    rename_column :tweeted_words, :lng, :lon
  end
end
