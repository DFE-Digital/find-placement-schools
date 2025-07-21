class Organisation < ApplicationRecord
  has_one :organisation_contact
  has_one :organisation_address

  has_many :placement_preferences
  has_many :user_memberships
  has_many :users, through: :user_memberships

  validates :name, presence: true
end
