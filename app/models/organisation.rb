class Organisation < ApplicationRecord
  has_one :organisation_contact
  has_one :organisation_address

  has_many :user_memberships
  has_many :users, through: :user_memberships

  validates :name, presence: true

  delegate :address_1, :address_2, :address_3, :town, :postcode, to: :organisation_address, prefix: false, allow_nil: true

  geocoded_by :address_string

  def address_string
    [
     address_1,
     address_2,
     address_3,
     town,
     postcode
    ].compact_blank.join(", ")
  end
end
