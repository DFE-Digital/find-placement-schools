class CreateOrganisationAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :organisation_addresses, id: :uuid do |t|
      t.references :organisation, null: false, foreign_key: true, type: :uuid
      t.string :address_1
      t.string :address_2
      t.string :address_3
      t.string :town
      t.string :city
      t.string :county
      t.string :postcode
      t.timestamps
    end
  end
end
