class AddLocationAndLikesToUsers < ActiveRecord::Migration
  def change
     add_column :users, :location, :string
     add_column :users, :likes, :string
  end
end
