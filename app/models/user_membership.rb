class UserMembership < ApplicationRecord
  belongs_to :user
  belongs_to :organisation

  validates :user, uniqueness: { scope: :organisation_id }
end
