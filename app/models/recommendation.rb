class Recommendation
  attr_accessor :user, :video, :user_keywords_array
  def initialize(user, video)
    @user = user
    @video = video
  end
  
  def video_tags_array
    @video['tags'].split(",").map{|tag| tag.gsub(" ", "_")}
  end
  
  def video_title_words_array
    @video['title'].split
  end
  
  def video_keywords_array
    (video_tags_array + video_title_words_array).uniq
  end
  
  def user_keywords_array=(keywords)
    @user_keywords_array = keywords
  end
  
  def dot_product(a, b)
    products = a.zip(b).map{|a, b| a * b}
    products.inject(0) {|s,p| s + p}
  end

  def magnitude(point)
    squares = point.map{|x| x ** 2}
    Math.sqrt(squares.inject(0) {|s, c| s + c})
  end

  def cosine_similarity(a, b)
    magnitude_product = magnitude(a) * magnitude(b)
    return 0 if magnitude_product == 0
    dot_product(a, b) / magnitude_product
  end

  def tags_to_point(tags_set, tags_space)
    tags_space.map{|c| tags_set.member?(c) ? 1 : 0}
  end

  def sort_by_similarity(items)
    by_these_tags = video_tags_array
    tags_space = by_these_tags + items.map{ |x| x['tags'].split(",") if x["tags"] }  
    tags_space.compact.flatten!.sort!.uniq!
    this_point = tags_to_point(by_these_tags, tags_space)
    other_points = items.map{ |i| [i, tags_to_point(i['tags'].split(","), tags_space)] if i['tags'] }
    similarities = other_points.compact.map{ |item, that_point| [item, cosine_similarity(this_point, that_point)] }
    sorted = similarities.sort { |a,b| b[1] <=>a[1] }
    return sorted.map{ |point,s| [point['id'] , s] }
  end  
  
  def most_similar_liked_media
    sort_by_similarity(@user.liked)[0..4]
  end
  
  def predict_rating
    sim_sum = 0
    most_similar_liked_media.each do |array|
      video_id = array[0]
      similarity = array[1]
      sim_sum += similarity
    end
    sim_sum = sim_sum/5
    sim_sum < 0.1 ? nil  : sim_sum 
  end
  
end