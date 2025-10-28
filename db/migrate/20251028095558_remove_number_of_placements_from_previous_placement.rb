class RemoveNumberOfPlacementsFromPreviousPlacement < ActiveRecord::Migration[8.0]
  def change
    safety_assured { remove_column :previous_placements, :number_of_placements, :integer }
  end
end
