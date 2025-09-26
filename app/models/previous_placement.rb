class PreviousPlacement < ApplicationRecord
  belongs_to :school
  belongs_to :placement_subject
  belongs_to :academic_year

  validates :number_of_placements, presence: true
  validates :school_id, uniqueness: { scope: [ :placement_subject_id, :academic_year_id ] }
end
