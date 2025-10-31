class MakeAcademicYearOptionalOnPlacementPreferences < ActiveRecord::Migration[7.0]
  def change
    # allow NULLs for the FK column
    change_column_null :placement_preferences, :academic_year_id, true
  end
end
