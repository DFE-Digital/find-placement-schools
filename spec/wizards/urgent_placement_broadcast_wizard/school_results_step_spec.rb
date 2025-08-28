require "rails_helper"

RSpec.describe UrgentPlacementBroadcastWizard::SchoolResultsStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(UrgentPlacementBroadcastWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        steps: { location_search: mock_location_search_step },
      )
    end
  end

  let(:mock_location_search_step) do
    instance_double(UrgentPlacementBroadcastWizard::LocationSearchStep).tap do |mock_location_search_step|
      allow(mock_location_search_step).to receive(:location).and_return("London")

      allow(mock_location_search_step).to receive(:radius).and_return(5)
    end
  end

  let(:attributes) { nil }
  let(:schools) { create_list(:school, 100) }

  before do
    stub_maps_request
    allow(Geocoder::Search).to receive(:call).and_return(
      OpenStruct.new(coordinates: [ 14.350231, 51.648438 ])
    )
    allow(SchoolsQuery).to receive(:call).and_return(schools)
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:location).to(:location_search_step) }
    it { is_expected.to delegate_method(:radius).to(:location_search_step) }
  end

  describe "#schools" do
    subject(:school_results) { step.schools }

    it "returns the schools within a radius of the location" do
      expect(school_results).to match_array(schools)
    end
  end

  describe "#first_25_schools" do
    subject(:first_25_schools) { step.first_25_schools }

    it "returns the schools within a radius of the location" do
      expect(first_25_schools).to match_array(schools.first(25))
    end
  end

  describe "#map_coordinates" do
    let(:map_coordinate) { step.map_coordinates }

    context "when more than 1 school is found" do
      it "returns the location coordinates" do
        expect(map_coordinate).to eq([ 14.350231, 51.648438 ])
      end
    end

    context "when only 1 school is found" do
      let(:schools) { create_list(:school, 1, latitude: 123, longitude: 456) }

      it "returns the coordinates of the school" do
        expect(map_coordinate).to eq([ 123, 456 ])
      end
    end
  end

  describe "#next_email_date" do
    subject(:next_email_date) { step.next_email_date }
    it "the date for next Friday" do
      Timecop.travel(Date.parse("1 September 2025")) do # Monday
        expect(next_email_date).to eq(Date.parse("5 September 2025")) # Friday
      end
    end
  end

  private

  def stub_maps_request
    stub_request(
      :get,
      "https://maps.googleapis.com/maps/api/geocode/json?address=,%20United%20Kingdom&key=1234&language=en&sensor=false",
      ).to_return(status: 200, body: "", headers: {})
  end
end
