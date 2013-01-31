class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :content
      t.integer :user_id
      t.string :media_id
      t.datetime :date_posted

      t.timestamps
    end
  end
end
