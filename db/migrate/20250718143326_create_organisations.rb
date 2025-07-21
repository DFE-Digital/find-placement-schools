class CreateOrganisations < ActiveRecord::Migration[8.0]
  def change
    create_table :organisations, id: :uuid do |t|
      t.string :name, null: false
      t.string :urn, index: true
      t.string :ukprn, index: true
      t.string :code, index: true
      t.float :longitude
      t.float :latitude
      t.string :email_address
      t.boolean :school
      t.boolean :provider
      t.timestamps
    end
  end
end
