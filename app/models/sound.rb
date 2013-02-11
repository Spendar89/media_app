require 'open-uri'

class Sound
  attr_accessor :url, :id, :title

  def initialize(url, start, page_id, category_id, tags_array, title=nil, description=nil)
    @url = url
    @id = parsed_json["id"]
    title.nil? ? @title = parsed_json["title"] : @title = title
    description.nil? ? @description = parsed_json["description"] : @description = description
    @start = start
    @uploaded = Time.now.to_i
    @page_id = page_id
    @category_id = category_id
    @tags = tags_array
  end


  def add_redis(current_user)
    $redis.hmset "media:#{@id}",:id, @id, :page_id, @page_id, :type, "soundcloud", :url, @url, 
                                :title, @title, :start, @start, :uploaded, @uploaded, 
                                :description, @description, :user, current_user.id,  :score, 0, :up, 0, :num_ratings, 0, :tags, @tags.join(",")
    $redis.zadd "media:by_upload", @uploaded, @id
    $redis.zadd "page:#{@page_id}:media:by_upload", @uploaded, @id
    $redis.sadd "media:soundcloud", @id
    $redis.zadd "user:#{current_user.id}:media:by_upload", @uploaded, @id
    $redis.zadd "user:#{current_user.id}:feed", @uploaded, "<aside><p class='feed-story'> <%= link_to '#{Time.now.strftime("%b %e, %l:%M %p")}: Added #{@title} to #{Page.find(@page_id).name}', 
                                                            '/pages/#{@page_id}', :method => 'get'%></p></aside>"
                                                            
    $redis.zadd "media:by_score", 0, @id
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

  private

  def to_json
    open("http://api.soundcloud.com/resolve.json?url=#{@url}&client_id=d3b8074244c4aeaf185e3eca51bf8baf").read
  end

  def parsed_json
    JSON.parse(to_json)
  end

  def self.to_json(url)
    open("http://api.soundcloud.com/resolve.json?url=#{url}&client_id=d3b8074244c4aeaf185e3eca51bf8baf").read
  end

  def self.parsed_json(url)
    JSON.parse(self.to_json(url))
  end


  def self.title(url)
    self.parsed_json(url)["title"]
  end

  def self.description(url)
    self.parsed_json(url)["description"]
  end

end
