class AddFieldsToOrganisationContact < ActiveRecord::Migration[8.0]
  def change
    add_column :organisation_contacts, :role, :string
    add_column :organisation_contacts, :telephone, :string
  end
end
