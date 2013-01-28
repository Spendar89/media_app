require 'open-uri'

class Video
  attr_accessor :id, :rating, :type, :url, :start, :title, :uploaded, :description
  
  def initialize(url, start, page_id, title, description)
    @url = url
    @id = yt_id
    @start = start
    @title = title
    @description = description
    @uploaded = Time.now.to_i
    @page_id = page_id
  end
  
  def add_redis(current_user)
      $redis.hmset "media:#{@id}", :yt_id, @id, :page_id, @page_id, :type, "youtube", :title, @title, 
                                     :start, @start, :uploaded, @uploaded, 
                                     :description, @description, :user, current_user.name, 
                                     :aspect_ratio, yt_aspect_ratio
      $redis.zadd "media:by_upload", @uploaded, @id
      $redis.zadd "page:#{@page_id}:media:by_upload", @uploaded, @id
      $redis.sadd "media:youtube", @id
  end
  
  def self.all_redis
    yt_ids = $redis.zrevrange "media:by_upload", 0, -1
    yt_ids.map! {|id| $redis.hgetall "media:#{id}"}
    yt_ids
  end
  
  def self.flush_db
    $redis.flushdb
  end
  
  def yt_id
    @url.split('v=')[-1]
  end
  
  def self.yt_id(url)
     url.split('v=')[-1]
  end
  
  def yt_aspect_ratio
    data= JSON.parse(open("https://gdata.youtube.com/feeds/api/videos/#{yt_id}?alt=json&v=2").read)["entry"]["media$group"]
    data["yt$aspectRatio"]["$t"] unless data["yt$aspectRatio"].nil?
  end
  
  def yt_title
    JSON.parse(open("https://gdata.youtube.com/feeds/api/videos/#{yt_id}?alt=json").read)["entry"]["title"]["$t"].gsub('"', '')
  end
  
  def self.yt_title(url)
    yt_id = self.yt_id(url)
    JSON.parse(open("https://gdata.youtube.com/feeds/api/videos/#{yt_id}?alt=json").read)["entry"]["title"]["$t"].gsub('"', '')
  end
  
  def yt_description
    JSON.parse(open("https://gdata.youtube.com/feeds/api/videos/#{yt_id}?alt=json").read)["entry"]["content"]["$t"].split(/\r?\n/)[0]
  end
  
  def self.yt_description(url)
    yt_id = self.yt_id(url)
    JSON.parse(open("https://gdata.youtube.com/feeds/api/videos/#{yt_id}?alt=json").read)["entry"]["content"]["$t"].split(/\r?\n/)[0]
  end
  
end
