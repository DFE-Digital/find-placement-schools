class CreatePlacementPreferenceReminders < ActiveRecord::Migration[8.1]
  def change
    create_table :placement_preference_reminders, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true, index: false
      t.references :organisation, type: :uuid, null: false, foreign_key: true, index: true
      t.references :academic_year, type: :uuid, null: false, foreign_key: true, index: true
      t.timestamps
    end

    add_index :placement_preference_reminders,
              %i[user_id organisation_id academic_year_id],
              name: "index_placement_preference_reminders_on_membership_and_year"
  end
end
