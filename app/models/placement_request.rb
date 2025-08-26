class PlacementRequest < ApplicationRecord
  belongs_to :provider, class_name: "Provider"
  belongs_to :school, class_name: "School"
  belongs_to :requested_by, class_name: "User"

  scope :sent, -> { where.not(sent_at: nil) }
  scope :not_sent, -> { where(sent_at: nil) }
end
