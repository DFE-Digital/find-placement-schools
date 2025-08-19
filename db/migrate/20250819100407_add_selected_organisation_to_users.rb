class AddSelectedOrganisationToUsers < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_reference :users, :selected_organisation, type: :uuid, index: { algorithm: :concurrently }
  end
end
