class User < ActiveRecord::Base
  attr_accessible :name, :provider, :uid, :followed_id
  validates_uniqueness_of :name, :case_sensitive => false
  has_many :pages
  has_many :comments
  has_many :follow_relationships, :foreign_key => "follower_id"
  has_many :following_pages, :through => :follow_relationships, :source => :followed
  
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["name"]
      user.image = auth["info"]["image"]
      user.location = auth["info"]["location"]
      user.oauth_token = auth.credentials.token
    end
  end
  
  def media_ids
    $redis.zrevrange "user:#{self.id}:media:by_upload", 0, -1
  end
  
  def follow_page(page)
    self.follow_relationships.create(:followed_id => page.id)
  end
  
  def following?(page)
    self.following_pages.include?(page)
  end
  
  def media
    media_ids.map{|id| $redis.hgetall "media:#{id}" }
  end
  
  def facebook
    @facebook ||= Koala::Facebook::API.new(oauth_token)
    block_given? ? yield(@facebook) : @facebook
    rescue Koala::Facebook::APIError => e
      logger.info e.to_s
      nil # or consider a custom null object
  end
  
  def like(media_id)
    unless liked?(media_id)
      $redis.zincrby "media:num_likes", 1, media_id
      $redis.sadd "media:#{media_id}:liked_by", self.id
      $redis.sadd "user:#{self.id}:likes", media_id
      like_tags(media_id)
    end
  end
  
  def like_tags(media_id)
    media = Medium.find(media_id)
    Medium.tags(media).each{ |tag| $redis.zincrby "tags:num_likes", 1, tag }
  end
  
  def recommend_media_score(medium)
    return nil if medium["tags"].empty?
    Recommendation.new(self, medium).predict_rating
  end
  
  def recommend_page_score(page)
    page_media = page.media
    havent_liked_ids_array = havent_liked_ids
    relevent_media = page_media.map do |medium|
      recommend_media_score(medium) unless liked?(medium["id"])
    end
    return false if relevent_media.compact.length < 5
    relevent_media.compact.inject(0){ |x,y| x + y }/page_media.length
  end
  
  def ranked_pages
    return false if liked_ids.length < 5
    pages = Page.all.map{|page| page if page.media_ids.length > 5 }.compact
    pages.sort_by! do |page| 
      page_score = recommend_page_score(page)
      page_score ? page_score : 0 
    end
  end
  
  def liked
     ids = $redis.smembers "user:#{self.id}:likes"
     Medium.find_all(ids).compact
  end
  
  def liked_ids
    $redis.smembers "user:#{self.id}:likes"
  end
  
  def liked?(media_id)
    $redis.sismember "user:#{self.id}:likes", media_id
  end
  
  def havent_liked_ids
    Medium.all_ids.map{ |id| id unless liked?(id) }.compact
  end
  
  def havent_liked
    ids = havent_liked_ids
    Medium.find_all(ids).compact
  end
  
  def recommended_media
    array = havent_liked.map do |medium|
      if medium["tags"]
        predicted_rating = Recommendation.new(self, medium).predict_rating
        [medium["id"], predicted_rating] if predicted_rating
      end
    end
    array.compact.sort{|x, y| x[1] <=> y[1] }
  end
  
  def most_recent_page_updated_feed
    page_feed = self.following_pages.map do |page|
      $redis.zrange "page:#{page.id}:feed", -1, -1, :withscores => true
    end
    page_feed.flatten!(1).sort!{ |x,y| y[1] <=> x[1] }[-1]
  end
  
end
