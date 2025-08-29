class Provider < Organisation
  validates :code, presence: true, uniqueness: true

  has_many :placement_requests, foreign_key: :provider_id, dependent: :destroy
end
