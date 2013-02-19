class Medium < ActiveRecord::Base
  
  def self.all_redis
    ids = $redis.zrevrange "media:by_upload", 0, -1
    ids.map! {|id| $redis.hgetall "media:#{id}"}
  end
    
  def self.all_ids
    $redis.zrevrange "media:by_upload", 0, -1
  end
  
  def self.find_all(ids_array)
    ids_array.map{ |id| $redis.hgetall "media:#{id}" }.map{|video| video unless video.empty?}.compact
  end
  
  def self.find(medium_id)
    $redis.hgetall "media:#{medium_id}"
  end
  
  def self.sort_by_date(media_array)
    media_array.sort{|x,y| y["uploaded"].to_i <=> x["uploaded"].to_i }
  end
  
  def self.seconds(minutes, seconds)
     minutes = 0 if minutes == ""
     seconds = 0 if seconds == ""
    (minutes.to_i*60) + seconds.to_i
  end
  
  def self.filtered_by_category(category_id)
    $redis.smembers "category:#{category_id}"
  end
  
  def self.has_category?(id, category_id)
    $redis.sismember "category:#{category_id}"
  end
  
  def self.filtered_by_tags(ids_array, tags_array)
    ids_array.map do |id|
      media_hash = $redis.hgetall "media:#{id}"
      id if self.has_tags?(id, tags_array)
    end
  end
  
  def self.has_tags?(media_id, tags_array)
    tags_array.each do |tag|
      response = $redis.sismember "tag:#{tag}", media_id
      return false unless response
    end
    return true
  end
  
  def self.find_all(ids_array)
    ids_array.map{ |id| $redis.hgetall "media:#{id}" }
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
  
  def self.add_category(media_id, category_id)
    $redis.sadd "category:#{category_id}", media_id
    $redis.zincrby "categories:by_count", 1, category_id
  end
  
end