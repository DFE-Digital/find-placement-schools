class School < Organisation
  attribute :transit_travel_duration
  attribute :walk_travel_duration
  attribute :drive_travel_duration

  validates :urn, presence: true, uniqueness: true

  has_many :placement_preferences, foreign_key: :organisation_id
  has_many :user_memberships, foreign_key: :organisation_id
  has_many :users, through: :user_memberships

  scope :without_preference_for, ->(academic_year) {
    where.not(
      id: PlacementPreference.where(academic_year_id: academic_year).select(:organisation_id)
    )
  }

  def self.users_without_preference_for(academic_year)
    User.joins(:user_memberships)
        .where(user_memberships: { organisation_id: without_preference_for(academic_year).select(:id) })
        .distinct
  end

  def placement_preference_for(academic_year:)
    placement_preferences
      .where(academic_year:)
      .order(created_at: :desc)
      .first
  end
end
