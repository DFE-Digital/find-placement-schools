class CreatePlacementPreferences < ActiveRecord::Migration[8.0]
  def change
    create_enum :appetite, %w[actively_looking interested not_open]

    create_table :placement_preferences, id: :uuid do |t|
      t.references :academic_year, null: false, foreign_key: true, type: :uuid
      t.references :organisation, null: false, foreign_key: true, type: :uuid
      t.references :created_by, null: false, type: :uuid
      t.enum :appetite, enum_type: "appetite"
      t.jsonb :placement_details
      t.timestamps
    end
  end
end
