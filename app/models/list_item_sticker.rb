class ListItemSticker < ApplicationRecord
  belongs_to :list_item
  belongs_to :sticker

  validates :sticker_id, uniqueness: { scope: :list_item_id }
end
