class Category < ActiveRecord::Base
  attr_accessible :name
  has_many :pages
  
  def self.reset
    self.find_each { |cat| cat.destroy }
    categories = [ "music", "comedy", "film", "television", "gaming", "fashion", "automotive", 
    "animation", "sports", "technology", "business", "science", "education", 
    "cooking", "health", "fitness", "causes", "news", "politics", "lifestyle", "weird" ]
    categories.each do |cat|
      Category.create(:name => cat)
    end 
  end
  
end
