class ListItem < ApplicationRecord
  belongs_to :list
  belongs_to :movie

  has_many :list_item_stickers, dependent: :destroy
  has_many :stickers, through: :list_item_stickers

  validates :movie_id, uniqueness: { scope: :list_id }
  validates :rating, numericality: { only_integer: true, in: 1..5 }, allow_nil: true

  default_scope -> { order(:position) }
end
