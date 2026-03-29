
class Blend < ApplicationRecord
  belongs_to :movie
  belongs_to :user
  belongs_to :ingredient1, class_name: 'Movie'
  belongs_to :ingredient2, class_name: 'Movie'
  belongs_to :hint, class_name: 'Movie', optional: true

  validates :ingredient1, presence: true
  validates :ingredient2, presence: true
  validate :ingredients_must_be_distinct
  validate :no_duplicate_blend_for_user

  def ingredients_must_be_distinct
    if ingredient1_id == ingredient2_id || ingredient1_id == hint_id || (ingredient2_id.present? && ingredient2_id == hint_id)
      errors.add(:base, 'Blend ingredients must be distinct movies')
    end
  end

  def no_duplicate_blend_for_user
    scope = Blend.where(movie_id: movie_id, user_id: user_id, ingredient1_id: ingredient1_id, ingredient2_id: ingredient2_id)
    scope = scope.where(hint_id: hint_id) if hint_id.present?
    if persisted?
      scope = scope.where.not(id: id)
    end
    if scope.exists?
      errors.add(:base, 'You have already created this blend for this movie')
    end
  end
end
