class Sticker < ApplicationRecord
  belongs_to :user, optional: true

  has_many :list_item_stickers, dependent: :destroy
  has_many :list_items, through: :list_item_stickers

  validates :label, presence: true, length: { maximum: 30 }
  validates :color, presence: true, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "must be a valid hex color (e.g. #D94F3D)" }

  scope :presets, -> { where(preset: true) }
  scope :custom_for, ->(user) { where(preset: false, user: user) }
end
