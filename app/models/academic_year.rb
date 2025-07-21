class AcademicYear < ApplicationRecord
  has_many :placement_preferences

  validates :name, presence: true
  validates :starts_on, presence: true
  validates :ends_on, presence: true, comparison: { greater_than_or_equal_to: :starts_on }
end
