class PlacementSubject < ApplicationRecord
  belongs_to :parent_subject, class_name: "PlacementSubject", optional: true

  has_many :child_subjects, class_name: "PlacementSubject", foreign_key: :parent_subject_id, dependent: :destroy

  validates :name, presence: true
  validates :code, presence: true

  enum :phase,
       { primary: "primary", secondary: "secondary" },
       validate: true
end
