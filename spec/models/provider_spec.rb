require 'rails_helper'

RSpec.describe Provider, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:code) }
  end
end
