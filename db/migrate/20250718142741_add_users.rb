class AddUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email_address, null: false, index: { unique: true }
      t.boolean :admin, default: false
      t.uuid :dfe_sign_in_uid
      t.datetime :last_signed_in_at

      t.timestamps
    end
  end
end
