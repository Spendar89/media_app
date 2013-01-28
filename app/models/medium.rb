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
  
  def self.search_results(query)
    matches = $redis.keys "*#{query}*"
    unless matches.nil?
      @media_array = []
      matches.each do |match|
        media_ids = $redis.smembers match
        media_ids.each { |media_id| @media_array << media_id unless @media_array.include?(media_id) }
      end
      @media_array.map{ |id| $redis.hgetall "media:#{id}" }  
    end
  end
  
end
