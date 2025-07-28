class ChangePlacementSubjectsCodeToNullTrue < ActiveRecord::Migration[8.0]
  def change
    change_column_null :placement_subjects, :code, true
  end
end
