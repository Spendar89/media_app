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
    media_hashes= media_ids.map{|id| $redis.hgetall "media:#{id}" }
    media_hashes
  end
  
  def facebook
    @facebook ||= Koala::Facebook::API.new(oauth_token)
    block_given? ? yield(@facebook) : @facebook
    rescue Koala::Facebook::APIError => e
      logger.info e.to_s
      nil # or consider a custom null object
  end
  
  def fb_likes
    fb_likes.map{|like| like['name']}
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
      learn_taste(media_id, :up)
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
      learn_taste(media_id, :down)
    end
  end
  
  def learn_taste(media_id, up_or_down)
    learn_category(media_id, up_or_down)
    learn_tags(media_id, up_or_down)
  end
  
  def learn_category(media_id, up_or_down)
    category_id = $redis.hget "media:#{media_id}", 'category_id'
    $redis.zincrby "user:#{self.id}:categories:by_votes", 1, category_id
    num_votes = $redis.zscore "user:#{self.id}:categories:by_votes", category_id
    $redis.zincrby "user:#{self.id}:categories:by_vote_up", 1, category_id if up_or_down == :up
    num_up = $redis.zscore "user:#{self.id}:categories:by_vote_up", category_id
    new_score = (num_up/num_votes).to_f 
    $redis.zadd "user:#{self.id}:categories:by_score", new_score, category_id
  end
  
  def learn_tags(media_id, up_or_down)
    tags = $redis.hget "media:#{media_id}", 'tags'
    tags.split(",").each do |tag|
      unless tag == ""
        $redis.zincrby "user:#{self.id}:tags:by_votes", 1, tag
        num_votes = $redis.zscore "user:#{self.id}:tags:by_votes", tag
        $redis.zincrby "user:#{self.id}:tags:by_vote_up", 1, tag if up_or_down == :up
        num_up = $redis.zscore "user:#{self.id}:tags:by_vote_up", tag
        new_score = (num_up/num_votes).to_f 
        $redis.zadd "user:#{self.id}:tags:by_score", new_score, tag
      end
    end
  end
  
  def fav_categories
    $redis.zrevrange "user:#{self.id}:categories:by_score", 0, -1, :withscores => true
  end
  
  def fav_tags
    $redis.zrevrange "user:#{self.id}:tags:by_score", 0, -1, :withscores => true
  end
  
  def category_score(media_id)
    media_category_id = $redis.hget "media:#{media_id}", 'category_id'
    overall_score = $redis.zscore "user:#{self.id}:categories:by_score", media_category_id
    (overall_score.to_f * 50)
  end

  def tag_score(media_id)
    overall_score = 0
    tags_counted = 0
    tags = $redis.hget "media:#{media_id}", 'tags'
    tags.split(",").each do |tag|
      tag_score = $redis.zscore "user:#{self.id}:tags:by_score", tag
      unless tag_score.nil?
        overall_score += (tag_score * 50)
        tags_counted += 1
      end
    end
    tags_counted = 1 if tags_counted == 0
    ((overall_score/tags_counted).to_f)
  end

  
  def enough_tag_votes?(tag)
    checker = $redis.zscore "user:#{self.id}:tags:by_score", tag
    !checker.nil?
  end
  
  def recommend_media_score(media_id)
    medium = Medium.find(media_id)
    Recommendation.new(self, medium).predict_rating
  end
  
  def reccomend_page_score(page_id)
    page = Page.find(page_id)
    page_media = page.media
    return false if page.media.length < 2
    page_media.map{ |medium| recommend_media_score(medium['id']) }.compact.inject(0){ |x,y| x + y }/page_media.length
  end
  
  def ranked_pages
    Page.all.sort_by! do |page| 
      page_score = reccomend_page_score(page.id)
      page_score ? page_score : 0 
    end
  end
  
  def count_vote(media_id)
    $redis.sadd "user:#{self.id}:votes", media_id  
  end
  
  def already_voted?(media_id)
    $redis.sismember "user:#{self.id}:votes", media_id 
  end
  
  def rated_videos
     ids = $redis.smembers "user:#{self.id}:votes"
     Medium.find_all(ids)
  end
  
  def voted_up?(media_id)
    $redis.sismember "user:#{self.id}:voted_up", media_id
  end
  
  def voted_down?(media_id)
    $redis.sismember "user:#{self.id}:voted_down", media_id
  end
  
  def havent_voted
    ids = Medium.all_ids.map{ |id| id unless already_voted?(id) }.compact
    Medium.find_all(ids).compact
  end
  
  def recommended_media
    array = havent_voted.map do |medium|
      if medium["tags"]
        predicted_rating = Recommendation.new(self, medium).predict_rating
        [medium["id"], predicted_rating] if predicted_rating
      end
    end
    array.compact.sort{|x, y| x[1] <=> y[1] }
  end
  
end
