class User < ActiveRecord::Base
  attr_accessible :name, :provider, :uid
  validates_uniqueness_of :name, :case_sensitive => false
  has_many :pages
  
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["name"]
      user.image = auth["info"]["image"]
      user.location = auth["info"]["location"]
      user.likes = auth["extra"]
    end
  end
  
  def media_ids
    $redis.zrevrange "user:#{self.id}:media:by_upload", 0, -1
  end
  
  def media
    media_hashes= media_ids.map{|id| $redis.hgetall "media:#{id}" }
    media_hashes
  end
  
  def vote_up(media_id)
    unless already_voted?(media_id)
      number_ratings = $redis.hget "media:#{media_id}", "num_ratings"
      up = $redis.hget "media:#{media_id}", "up"
      score = ((up.to_f + 1).to_f/(number_ratings.to_f + 1)).to_f
      $redis.hset "media:#{media_id}", "num_ratings", number_ratings.to_f + 1
      $redis.hset "media:#{media_id}", "up", up.to_f + 1
      $redis.hset "media:#{media_id}", "score", score
      $redis.zadd "media:by_score", score, media_id
      $redis.sadd "user:#{self.id}:voted_up", media_id
      count_vote(media_id)
    end
  end
  
  def vote_down(media_id)
     unless already_voted?(media_id)
      number_ratings = $redis.hget "media:#{media_id}", "num_ratings"
      up = $redis.hget "media:#{media_id}", "up"
      score = ((up.to_f).to_f/(number_ratings.to_f + 1)).to_f
      $redis.hset "media:#{media_id}", "num_ratings", number_ratings.to_f + 1
      $redis.hset "media:#{media_id}", "score", score
      $redis.zadd "media:by_score", score, media_id
      $redis.sadd "user:#{self.id}:voted_down", media_id
      count_vote(media_id)
    end
  end
  
  def count_vote(media_id)
    $redis.sadd "user:#{self.id}:votes", media_id  
  end
  
  def already_voted?(media_id)
    $redis.sismember "user:#{self.id}:votes", media_id 
  end
  
  def voted_up?(media_id)
    $redis.sismember "user:#{self.id}:voted_up", media_id
  end
  
  def voted_down?(media_id)
    $redis.sismember "user:#{self.id}:voted_down", media_id
  end
  
end
