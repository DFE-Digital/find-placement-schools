class Provider < Organisation
  validates :code, presence: true, uniqueness: true
end
