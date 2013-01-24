class AddUploadedToVideos < ActiveRecord::Migration
  def change
     add_column :videos, :uploaded, :integer
  end
end
