class User < ApplicationRecord
  belongs_to :selected_organisation, class_name: "Organisation", optional: true

  has_many :user_memberships
  has_many :organisations, through: :user_memberships
  has_many :schools, -> { where(type: "School") }, through: :user_memberships, source: :organisation
  has_many :providers, -> { where(type: "Provider") }, through: :user_memberships, source: :organisation
  has_many :placement_preferences, class_name: "PlacementPreference", foreign_key: :created_by_id

  normalizes :email_address, with: ->(email_address) { email_address.strip.downcase }

  validates :first_name, :last_name, presence: true
  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "Please enter a valid email address" }

  def full_name
    "#{first_name} #{last_name}"
  end
end
