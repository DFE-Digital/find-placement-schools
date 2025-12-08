require "rails_helper"

describe ProvidersQuery do
  subject(:query) { described_class.new(params:) }

  let(:params) { {} }

  let(:query_provider) { create(:provider, name: "Ministry of Magic", ukprn: "12345678") }
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
      context "when a name is provided" do
        let(:params) { { filters: { search_by_name: "Ministry" } } }

        it "returns the filtered providers" do
          expect(query.call).to include(query_provider)
          expect(query.call).not_to include(non_query_provider)
        end
      end

      context "when a ukprn is provided" do
        let(:params) { { filters: { search_by_name: query_provider.ukprn } } }

        it "returns the filtered providers" do
          expect(query.call).to include(query_provider)
          expect(query.call).not_to include(non_query_provider)
        end
      end

      context "when a postcode is provided" do
        let(:params) { { filters: { search_by_name: "AB1 2CD" } } }

        before do
          create(:organisation_address, organisation: query_provider, postcode: "AB1 2CD")
        end

        it "returns the filtered providers" do
          expect(query.call).to include(query_provider)
          expect(query.call).not_to include(non_query_provider)
        end
      end

      context "when a mixed case postcode is provided" do
        let(:params) { { filters: { search_by_name: "aB1 2cD" } } }

        before do
          create(:organisation_address, organisation: query_provider, postcode: "AB1 2CD")
        end

        it "returns the filtered providers" do
          expect(query.call).to include(query_provider)
          expect(query.call).not_to include(non_query_provider)
        end
      end

      context "when a partial postcode is provided" do
        let(:params) { { filters: { search_by_name: "AB1" } } }

        before do
          create(:organisation_address, organisation: query_provider, postcode: "AB1 2CD")
        end

        it "returns the filtered providers" do
          expect(query.call).to include(query_provider)
          expect(query.call).not_to include(non_query_provider)
        end
      end
    end
  end
end
