class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :type
      t.string :name
      t.string :url
      t.integer :rating

      t.timestamps
    end
  end
end
