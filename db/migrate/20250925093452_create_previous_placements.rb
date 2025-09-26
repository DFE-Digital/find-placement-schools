class CreatePreviousPlacements < ActiveRecord::Migration[8.0]
  def change
    create_table :previous_placements, id: :uuid do |t|
      t.references :school, null: false, foreign_key: { to_table: :organisations }, type: :uuid
      t.references :academic_year, null: false, foreign_key: true, type: :uuid
      t.references :placement_subject, null: false, foreign_key: true, type: :uuid
      t.integer :number_of_placements, null: false, default: 0
    end

    add_index :previous_placements, [ :school_id, :placement_subject_id, :academic_year_id ], unique: true
  end
end
