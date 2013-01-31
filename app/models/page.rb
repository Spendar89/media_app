class Page < ActiveRecord::Base
  attr_accessible :category_id, :name, :user_id
  validates_uniqueness_of :name, :case_sensitive => false
  belongs_to :user
  belongs_to :category
  
  def media_ids
    $redis.zrevrange "page:#{self.id}:media:by_upload", 0, -1
  end
  
  def media
    media_ids.map{|id| $redis.hgetall "media:#{id}" }
  end
  
  def add_to_feed(current_user)
    $redis.zadd "user:#{current_user.id}:feed", Time.now.to_i, "<aside><p class='feed-story'><%= link_to '#{Time.now.strftime("%b %e, %l:%M %p")}: 
                                                                Created Page #{self.name}', '/pages/#{self.id}', :method => 'get'%></p></aside>"
  end

end
