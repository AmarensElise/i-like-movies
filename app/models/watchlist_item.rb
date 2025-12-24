class WatchlistItem < ApplicationRecord
  belongs_to :user
  belongs_to :movie

  validates :pitch, length: { maximum: 500 }, allow_blank: true
end