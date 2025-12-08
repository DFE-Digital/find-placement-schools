class PreviousPlacement < ApplicationRecord
  belongs_to :school
  belongs_to :placement_subject
  belongs_to :academic_year

  validates :school_id, uniqueness: { scope: [ :placement_subject_id, :academic_year_id ] }

  delegate :name, to: :placement_subject, prefix: true
  delegate :name, to: :academic_year, prefix: true
end
