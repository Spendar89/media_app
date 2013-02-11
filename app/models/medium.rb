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
    matched_ids = []
    tags_array = query.split(",")
    tags_array.each do |tag|
      ids = $redis.smembers "tag:#{tag}"
      ids.each{|id| matched_ids << id unless matched_ids.include?(id)}
    end
    matched_ids.map! do |id|
        $redis.hgetall "media:#{id}" if self.each_has_tag?(tags_array, id)
    end
    matched_ids.sort{ |x,y| y["uploaded"].to_i <=> x["uploaded"].to_i }
  end
  
  
  
  
end
