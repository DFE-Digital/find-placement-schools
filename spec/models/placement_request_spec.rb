require 'rails_helper'

RSpec.describe PlacementRequest, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:school) }
    it { is_expected.to belong_to(:requested_by).class_name("User") }
  end

  describe "scopes" do
    let(:sent_placement_request) { create(:placement_request, :sent) }
    let(:unsent_placement_request) { create(:placement_request) }

    before do
      sent_placement_request
      unsent_placement_request
    end

    describe "sent" do
      subject(:sent) { described_class.sent }

      it "returns only placement requests that have been sent" do
        expect(sent).to contain_exactly(sent_placement_request)
      end
    end

    describe "not_sent" do
      subject(:not_sent) { described_class.not_sent }

      it "returns only placement requests that have not been sent" do
        expect(not_sent).to contain_exactly(unsent_placement_request)
      end
    end
  end
end
