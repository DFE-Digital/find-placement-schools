# Records each placement preference reminder email sent, so a user is reminded
# a limited number of times per school and academic year, regardless of how
# often they sign in.
class PlacementPreferenceReminder < ApplicationRecord
  belongs_to :user
  belongs_to :organisation
  belongs_to :academic_year
end
