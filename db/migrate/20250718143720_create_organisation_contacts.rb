class CreateOrganisationContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :organisation_contacts, id: :uuid do |t|
      t.references :organisation, null: false, foreign_key: true, type: :uuid
      t.string :first_name
      t.string :last_name
      t.string :email_address, null: false, index: true
      t.timestamps
    end
  end
end
