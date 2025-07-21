class AddPartialUniqueIndexToOrganisationsUrn < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    remove_index :organisations, name: "index_organisations_on_urn", algorithm: :concurrently
    add_index :organisations, :urn, unique: true, where: "type = 'School'", algorithm: :concurrently
  end
end
