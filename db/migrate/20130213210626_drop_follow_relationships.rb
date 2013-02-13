class DropFollowRelationships < ActiveRecord::Migration
def change
   drop_table :follow_relationships
end
end
