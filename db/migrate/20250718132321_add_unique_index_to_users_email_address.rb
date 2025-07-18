class AddUniqueIndexToUsersEmailAddress < ActiveRecord::Migration[8.0]
  def change
    add_index :users, :email_address, unique: true
  end
end
