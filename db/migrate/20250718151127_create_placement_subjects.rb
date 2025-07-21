class CreatePlacementSubjects < ActiveRecord::Migration[8.0]
  def change
    create_enum :phase, %w[primary secondary]

    create_table :placement_subjects, id: :uuid do |t|
      t.string :name, null: false
      t.string :code, null: false, index: { unique: true }
      t.enum :phase, enum_type: "phase"
      t.references :parent_subject, type: :uuid
      t.timestamps
    end
  end
end
