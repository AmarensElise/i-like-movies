class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :watchlist_items, dependent: :destroy
  has_many :viewings, dependent: :destroy
  has_many :favorite_actors, dependent: :destroy
  has_many :lists, dependent: :destroy
  has_many :movie_likes, dependent: :destroy
  has_many :movie_like_votes, dependent: :destroy
  has_many :quizzes, dependent: :destroy
  has_many :watch_quiz_sessions, dependent: :destroy

  before_validation :normalize_username

  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       format: { with: /\A[a-z0-9_-]{3,20}\z/i }
  validates :country_code, length: { is: 2 }, allow_nil: true, format: { with: /\A[A-Z]{2}\z/, allow_blank: true }

  def home_country
    country_code.presence || "US"
  end

  private

  def normalize_username
    self.username = username.to_s.strip.downcase
  end
end
