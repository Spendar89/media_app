class Page < ActiveRecord::Base
  attr_accessible :category_id, :name, :user_id
  belongs_to :user
  belongs_to :category
  
  def media_ids
    $redis.zrevrange "page:#{self.id}:media:by_upload", 0, -1
  end
  
  def media
    media_hashes= media_ids.map{|id| $redis.hgetall "media:#{id}" }
    media_hashes
  end

end
