class PreviousPlacement < ApplicationRecord
  belongs_to :school
  belongs_to :academic_year

  validates :school_id, uniqueness: { scope: [ :subject_name, :academic_year_id ] }

  delegate :name, to: :academic_year, prefix: true

  scope :order_by_name, -> { order(:subject_name) }
end
