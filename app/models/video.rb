require 'open-uri'

class Video
  attr_accessor :id, :rating, :type, :url, :start, :title, :uploaded, :description
  
  def initialize(url, start, page_id, category_id, tags_array, title, description)
    @url = url
    @id = yt_id
    @start = start
    @title = title
    @description = description
    @uploaded = Time.now.to_i
    @page_id = page_id
    @category_id = category_id
    @tags = tags_array
  end
  
  def add_redis(current_user)
      $redis.hmset "media:#{@id}", :id, @id, :page_id, @page_id, :page_name, @page_id, :category_id, @category_id, :type, "youtube", :title, @title, 
                                     :start, @start, :uploaded, @uploaded, 
                                     :description, @description, :user, current_user.id, 
                                     :aspect_ratio, yt_aspect_ratio, :score, 0, :up, 0, :num_ratings, 0, :tags, @tags.join(",")
      $redis.zadd "media:by_upload", @uploaded, @id
      $redis.zadd "page:#{@page_id}:media:by_upload", @uploaded, @id
      $redis.zadd "user:#{current_user.id}:media:by_upload", @uploaded, @id
      $redis.zadd "media:by_score", 0, @id
      $redis.sadd "media:youtube", @id
      $redis.zadd "user:#{current_user.id}:feed", @uploaded, @id
      $redis.zadd "page:#{@page_id}:feed", @uploaded, @id
      add_category
      add_tag unless @tags.nil?
  end
  
  def add_tag
    @tags.each do |tag|
      $redis.sadd "tags", tag
      $redis.sadd "tag:#{tag}", @id
      $redis.zincrby "tags:by_count", 1, tag
    end
  end
  
  def add_category
    $redis.sadd "category:#{@category_id}", @id
    $redis.zincrby "categories:by_count", 1, @category_id
  end
  
  
  def self.all_redis
    yt_ids = $redis.zrevrange "media:by_upload", 0, -1
    yt_ids.map! {|id| $redis.hgetall "media:#{id}"}
    yt_ids
  end
  
  def self.find(id)
    $redis.hgetall "media:#{id}"
  end
  
  def self.tags(id)
    self.find(id)["tags"].split(",")
  end
  
  def self.set_tags
    self.all_redis.each do |video|
      self.tags(video["id"]).each {|tag| $redis.zincrby "tags:by_count", 1, tag }
    end
  end
  
  def self.flush_db
    $redis.flushdb
  end
  
  def yt_id
    @url.split('v=')[-1][0..10]
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
