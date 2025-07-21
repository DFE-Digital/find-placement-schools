class AddGIASFieldsToOrganisation < ActiveRecord::Migration[8.0]
  def change
    # Strong Migrations cannot read change_table blocks, so we need to use add_column instead
    add_column :organisations, :admissions_policy, :string
    add_column :organisations, :district_admin_code, :string
    add_column :organisations, :district_admin_name, :string
    add_column :organisations, :gender, :string
    add_column :organisations, :group, :string
    add_column :organisations, :last_inspection_date, :date
    add_column :organisations, :local_authority_code, :string
    add_column :organisations, :local_authority_name, :string
    add_column :organisations, :maximum_age, :integer
    add_column :organisations, :minimum_age, :integer
    add_column :organisations, :percentage_free_school_meals, :integer
    add_column :organisations, :phase, :string
    add_column :organisations, :rating, :string
    add_column :organisations, :religious_character, :string
    add_column :organisations, :school_capacity, :integer
    add_column :organisations, :send_provision, :string
    add_column :organisations, :special_classes, :string
    add_column :organisations, :telephone, :string
    add_column :organisations, :total_boys, :integer
    add_column :organisations, :total_girls, :integer
    add_column :organisations, :total_pupils, :integer
    add_column :organisations, :type_of_establishment, :string
    add_column :organisations, :urban_or_rural, :string
    add_column :organisations, :website, :string
  end
end
