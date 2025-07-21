class CreateUserMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :user_memberships, id: :uuid do |t|
      t.references :organisation, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end
