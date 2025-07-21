require 'rails_helper'

RSpec.describe OrganisationAddress, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:organisation) }
  end
end
