class AddUniqueIndexToOrganisationAddressOrganisationId < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    remove_index :organisation_addresses, name: "index_organisation_addresses_on_organisation_id", algorithm: :concurrently
    add_index :organisation_addresses, :organisation_id, unique: true, algorithm: :concurrently
  end
end
