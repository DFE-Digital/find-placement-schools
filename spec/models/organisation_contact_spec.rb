require 'rails_helper'

RSpec.describe OrganisationContact, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:organisation) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email_address) }
  end
end
