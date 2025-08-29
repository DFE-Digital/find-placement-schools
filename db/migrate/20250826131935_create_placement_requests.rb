class CreatePlacementRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :placement_requests, id: :uuid do |t|
      t.references :school, type: :uuid, null: false, foreign_key: { to_table: 'organisations' }
      t.references :provider, type: :uuid, null: false, foreign_key: { to_table: 'organisations' }
      t.references :requested_by, type: :uuid, null: false, foreign_key: { to_table: 'users' }
      t.datetime :sent_at
      t.timestamps
    end
  end
end
