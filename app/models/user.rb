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
    end
  end
  
  def media_ids
    $redis.zrevrange "user:#{self.id}:media:by_upload", 0, -1
  end
  
  def media
    media_hashes= media_ids.map{|id| $redis.hgetall "media:#{id}" }
    media_hashes
  end
  
end
