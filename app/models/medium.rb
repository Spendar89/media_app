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
  
  def self.has_tags?(media_id, tags_array)
    tags_array.each do |tag|
      response = $redis.sismember "tag:#{tag}", media_id
      return false unless response
    end
    return true
  end
  
  def self.search_results(query)
    matched_ids = []
    tags_array = query.split("|")
    tags_array.each do |tag|
      ids = $redis.smembers "tag:#{tag}"
      ids.each{|id| matched_ids << id unless matched_ids.include?(id)}
    end 
    puts "matched ids: #{matched_ids}"
    filtered_matches =[]
    matched_ids.each do |id|
        match_hatch = $redis.hgetall "media:#{id}" if self.has_tags?(id, tags_array)
        filtered_matches << match_hatch unless match_hatch.nil?
    end
    puts "new matched ids: #{matched_ids}"
    return filtered_matches.sort{ |x,y| y["uploaded"].to_i <=> x["uploaded"].to_i }
  end
  
end