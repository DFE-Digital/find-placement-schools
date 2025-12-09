class RemovePlacementSubjectFromPreviousPlacement < ActiveRecord::Migration[8.1]
  def up
    # Table not used in production at this point in time
    safety_assured do
      remove_foreign_key :previous_placements, :placement_subjects
      remove_index :previous_placements, name: "idx_on_school_id_placement_subject_id_academic_year_290aca342d"
      remove_column :previous_placements, :placement_subject_id

      add_column :previous_placements, :subject_name, :string
    end
  end

  def down
    # raise ActiveRecord::IrreversibleMigration
  end
end
