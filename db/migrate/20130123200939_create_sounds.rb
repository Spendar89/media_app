class CreateSounds < ActiveRecord::Migration
  def change
    create_table :sounds do |t|
      t.integer :rating
      t.string :url
      t.integer :start
      t.string :title
      t.integer :uploaded
      t.string :description
      t.integer :user_id

      t.timestamps
    end
  end
end
