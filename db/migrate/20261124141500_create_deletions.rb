class CreateDeletions < ActiveRecord::Migration[8.1]
  def change
    create_table :deletions, id: :uuid do |t|
      t.string :entity_type, null: false
      t.uuid :entity_id, null: false
      t.string :table_names, array: true, null: false, default: []
      t.jsonb :deleted_records, null: false, default: {}
      t.datetime :deleted_at, null: false
      t.timestamps
    end

    add_index :deletions, %i[entity_type entity_id]
  end
end
