class User < ActiveRecord::Base
  include UserHelper

  enum role: [:user, :guest, :admin]
  has_many :blog_posts
  belongs_to :creator_user, class_name: :User

  after_initialize :set_default_role, :if => :new_record?

  scope :in_page, ->(page, with_size: 20) {
    offset = (page.to_i-1) * with_size.to_i
    limit(with_size.to_i).offset(offset)
  }

  def set_default_role
    self.role ||= :user
  end

  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable
  include DeviseTokenAuth::Concerns::User
end
