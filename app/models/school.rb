class School < Organisation
  validates :urn, presence: true, uniqueness: true

  has_many :placement_preferences, foreign_key: :organisation_id
end
