class CreateAcademicYears < ActiveRecord::Migration[8.0]
  def change
    create_table :academic_years, id: :uuid do |t|
      t.string :name, null: false, index: { unique: true }
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.timestamps
    end
  end
end
