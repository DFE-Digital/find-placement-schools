require "rails_helper"

describe ProvidersQuery do
  subject(:query) { described_class.new(params:) }

  let(:params) { {} }

  let(:query_provider) { create(:provider, name: "Ministry of Magic") }
  let(:non_query_provider) { create(:provider, name: "Order of the Phoenix") }

  before do
    query_provider
    non_query_provider
  end

  describe "#call" do
    it "returns all providers" do
      expect(query.call).to include(query_provider)
      expect(query.call).to include(non_query_provider)
    end

    context "when filtering by name" do
      let(:params) { { filters: { search_by_name: "Ministry" } } }

      it "returns the filtered providers" do
        expect(query.call).to include(query_provider)
        expect(query.call).not_to include(non_query_provider)
      end
    end
  end
end
