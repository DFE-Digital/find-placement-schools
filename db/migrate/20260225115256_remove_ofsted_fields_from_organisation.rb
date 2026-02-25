class RemoveOfstedFieldsFromOrganisation < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      remove_column :organisations, :rating, :string
      remove_column :organisations, :last_inspection_date, :datetime
    end
  end
end
