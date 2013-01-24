require 'open-uri'

class Sound
  attr_accessor :url, :id, :title
  
  def initialize(url, start)
    @url = url
    @id = parsed_json["id"]
    @title = parsed_json["title"]
    @description = parsed_json["description"]
    @start = start
  end
  
  
  def add_redis(current_user)
    uploaded = Time.now.to_i
    $redis.hmset "youtube:#{@id}", :sc_id, @id, :type, "soundcloud", :url, @url, :title, @title, :start, @start, :uploaded, uploaded, :description, @description, :user, current_user.name
    $redis.zadd "youtube:by_upload", uploaded, @id
  end
  
  private
  
    def to_json
      open("http://api.soundcloud.com/resolve.json?url=#{@url}&client_id=d3b8074244c4aeaf185e3eca51bf8baf").read
    end
  
    def parsed_json
      JSON.parse(to_json)
    end
  
end
