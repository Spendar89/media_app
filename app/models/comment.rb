class Comment < ActiveRecord::Base
  attr_accessible :content, :date_posted, :media_id, :user_id
end
