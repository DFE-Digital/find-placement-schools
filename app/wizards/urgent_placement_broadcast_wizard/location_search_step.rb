class UrgentPlacementBroadcastWizard::LocationSearchStep < BaseStep
  attribute :location
  attribute :radius

  validates :location, presence: true
  validates :radius,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 1 }
end