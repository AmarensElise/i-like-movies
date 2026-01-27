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
end
