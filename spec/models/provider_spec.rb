require 'rails_helper'

RSpec.describe Provider, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:code) }
  end

  describe "associations" do
    it { is_expected.to have_many(:placement_requests).dependent(:destroy) }
  end
end
