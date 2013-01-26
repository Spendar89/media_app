class Medium < ActiveRecord::Base
  
  def self.all_redis
    yt_ids = $redis.zrevrange "media:by_upload", 0, -1
    yt_ids.map! {|id| $redis.hgetall "media:#{id}"}
  end
  
  def self.seconds(minutes, seconds)
     minutes = 0 if minutes == ""
     seconds = 0 if seconds == ""
    (minutes.to_i*60) + seconds.to_i
  end
  
end
