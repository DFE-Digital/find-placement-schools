class User < ApplicationRecord
  belongs_to :selected_organisation, class_name: "Organisation", optional: true

  has_many :user_memberships
  has_many :organisations, through: :user_memberships
  has_many :placement_preferences, class_name: "PlacementPreference", foreign_key: :created_by_id
  has_many :placement_requests, foreign_key: :requested_by_id

  validates :first_name, :last_name, presence: true
  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "Please enter a valid email address" }
end
