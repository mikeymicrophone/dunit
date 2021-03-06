class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_save :ensure_authentication_token
 
  has_many :memberships
  has_many :projects, :through => :memberships
  has_many :comments

  def name
  	return email if first_name.blank?
  	"#{first_name} #{last_name}"
  end

  def name_with_email
    "#{name} <#{email}>"
  end

  def authorized? project
    project.memberships.find_by_user_id(id).andand.approved?
  end

  def requested? project
    project.memberships.find_by_user_id(id).andand.approved? == false
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def generate_random_password
  	self.password = Devise.friendly_token.first(8)
  end
 
  private
  
  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
