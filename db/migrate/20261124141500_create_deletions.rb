class CreateDeletions < ActiveRecord::Migration[8.1]
  def change
    create_table :deleted_entities, id: :uuid do |t|
      t.string :entity_id
      t.string :entity_name
      t.jsonb :deleted_records
      t.timestamps
    end
  end
end
