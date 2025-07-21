require 'rails_helper'

RSpec.describe School, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:placement_preferences) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:urn) }
  end
end
