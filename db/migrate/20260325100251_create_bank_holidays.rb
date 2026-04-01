class CreateBankHolidays < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    create_table :bank_holidays, id: :uuid do |t|
      t.string :title, null: false
      t.date :date, null: false
      t.timestamps
    end

    add_index :bank_holidays, :date, unique: true, if_not_exists: true, algorithm: :concurrently
  end
end
