class ShowRole < ApplicationRecord
  belongs_to :show
  belongs_to :actor

  validates :show_id, uniqueness: { scope: :actor_id, message: "Actor already has a role in this show" }
end
