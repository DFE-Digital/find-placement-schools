class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email_address
      t.boolean :admin, default: false
      t.uuid :dfe_sign_in_uid
      t.datetime :last_signed_in_at

      t.timestamps
    end
  end
end
