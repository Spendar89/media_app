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
  
  def self.each_has_tag?(tags_array, id)
    tags_array.each do |tag|
      ids = $redis.smembers "tag:#{tag}"
      return false unless ids.include?(id)
    end
    true
  end
  
  def self.search_results(query)
    matches = []
    query_array = query.split(",")
    query_array.each do |query|
      ids = $redis.smembers "tag:#{query}"
      matches << ids
    end
    matched_ids = matches.flatten.uniq
    matched_ids.map! do |id|
        $redis.hgetall "media:#{id}" if self.each_has_tag?(query_array, id)
    end
    matched_ids.sort{ |x,y| y["uploaded"].to_i <=> x["uploaded"].to_i }
  end
  
  
  
  
end
