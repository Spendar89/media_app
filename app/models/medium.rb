class Medium < ActiveRecord::Base
  
  def self.all_redis
    ids = $redis.zrevrange "media:by_upload", 0, -1
    ids.map! {|id| $redis.hgetall "media:#{id}"}
  end
  
  def self.seconds(minutes, seconds)
     minutes = 0 if minutes == ""
     seconds = 0 if seconds == ""
    (minutes.to_i*60) + seconds.to_i
  end
  
  def self.search_results(query)
    matches = []
    query.split(",").each do |query|
      ids = $redis.keys "tag:#{query}"
      matches << ids
    end
    matches = matches.flatten.uniq
    unless matches.empty?
      @media_array = []
      matches.each do |match|
        media_ids = $redis.smembers match
        media_ids.each { |media_id| @media_array << media_id unless @media_array.include?(media_id) }
      end
      @media_array.map{ |id| $redis.hgetall "media:#{id}" }.sort{ |x,y| y["uploaded"].to_i <=> x["uploaded"].to_i }  
    end
  end
  
  
  
  
end
