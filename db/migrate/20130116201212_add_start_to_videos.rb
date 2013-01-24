class AddStartToVideos < ActiveRecord::Migration
  def change
     add_column :videos, :start, :string
     add_column :videos, :title, :string
  end
end
