class AddSurveySentAtToUser < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :survey_sent_at, :datetime
  end
end
