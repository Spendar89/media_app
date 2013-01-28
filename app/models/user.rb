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
end
