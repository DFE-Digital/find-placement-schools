class AddIndexToOrganisationCode < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :organisations, [ :type, :code ], unique: true, where: "type = 'Provider'", algorithm: :concurrently
  end
end
