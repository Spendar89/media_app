class Page < ActiveRecord::Base
  attr_accessible :category_id, :name, :user_id, :description
  validates_uniqueness_of :name, :case_sensitive => false
  belongs_to :user
  belongs_to :category
  has_many :follow_relationships, :foreign_key => "followed_id"
  has_many :followers, :through => :follow_relationships
  
  def media_ids
    $redis.zrevrange "page:#{self.id}:media:by_upload", 0, -1
  end
  
  def media
    media_ids.map{|id| $redis.hgetall "media:#{id}" }
  end
  
  def add_to_feed(current_user)
    adjusted_name = self.name.gsub("'", "")
    $redis.zadd "user:#{current_user.id}:feed", Time.now.to_i, "<aside><p class='feed-story'><%= link_to '#{Time.now.strftime("%b %e, %l:%M %p")}: 
                                                                Created Page #{adjusted_name}', '/pages/#{self.id}', :method => 'get'%></p></aside>"
  end
   
  def add_redis
    $redis.set "page:#{self.id}:name", self.name
  end
  
  def number_of_followers
    self.followers.count
  end

end
