class Tag
  
  def self.all
    $redis.smembers "tags"
  end
  
  def self.find_all(tag)
    tags = $redis.smembers "tag:#{tag}"
    tags.map{|media_id| $redis.hgetall "media:#{media_id}"}
  end
  
  def self.ranked
    $redis.zrevrange "tags:by_count", 0, -1
  end
    
   
end