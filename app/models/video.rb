require 'open-uri'
class Video < ActiveRecord::Base
  attr_accessible :id, :name, :rating, :type, :url, :start, :title, :uploaded, :description
  
  def add_redis(current_user)
      $redis.hmset "youtube:#{yt_id}", :yt_id, yt_id, :type, "youtube", :title, yt_title, :start, self.start, :uploaded, Time.now.to_i, :description, yt_description, :user, current_user.name, :aspect_ratio, yt_aspect_ratio
      $redis.zadd "youtube:by_upload", self.uploaded, yt_id
  end
  
  def self.all_redis
    yt_ids = $redis.zrevrange "youtube:by_upload", 0, -1
    yt_ids.map! {|id| $redis.hgetall "youtube:#{id}"}
    yt_ids
  end
  
  def yt_id
    self.url.split('v=')[-1]
  end
  
  def yt_aspect_ratio
    data= JSON.parse(open("https://gdata.youtube.com/feeds/api/videos/#{yt_id}?alt=json&v=2").read)["entry"]["media$group"]
    data["yt$aspectRatio"]["$t"] unless data["yt$aspectRatio"].nil?
  end
  
  def yt_title
    JSON.parse(open("https://gdata.youtube.com/feeds/api/videos/#{yt_id}?alt=json").read)["entry"]["title"]["$t"].gsub('"', '')
  end
  
  def yt_description
    
    JSON.parse(open("https://gdata.youtube.com/feeds/api/videos/#{yt_id}?alt=json").read)["entry"]["content"]["$t"].split(/\r?\n/)[0]
  end
  
  def self.seconds(minutes, seconds)
   (minutes*60) + seconds
  end
  
end
