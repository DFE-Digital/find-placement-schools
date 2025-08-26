class School < Organisation
  attribute :transit_travel_duration
  attribute :walk_travel_duration
  attribute :drive_travel_duration

  validates :urn, presence: true, uniqueness: true

  has_many :placement_preferences, foreign_key: :organisation_id, dependent: :destroy
  has_many :placement_requests, foreign_key: :school_id, dependent: :destroy

  def placement_preference_for(academic_year:)
    placement_preferences
      .where(academic_year:)
      .order(created_at: :desc)
      .first
  end
end
