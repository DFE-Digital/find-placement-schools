require "rails_helper"

RSpec.describe UrgentPlacementBroadcastWizard do
  subject(:wizard) { described_class.new(state:, params:, provider:, current_step:, current_user:) }

  let(:provider) { create(:provider) }
  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:current_step) { nil }
  let(:current_user) { create(:user) }

  describe "#steps" do
    subject(:steps) { wizard.steps.keys }

    it { is_expected.to eq %i[location_search school_results] }
  end

  describe "#broadcast_to_schools" do
    subject(:broadcast_to_schools) { wizard.broadcast_to_schools }

    context "when the steps are valid" do
      let(:state) do
        {
          "location_search" => { "location" => "London", "radius" => 5 }
        }
      end
      let(:schools) { create_list(:school, 5) }

      before do
        stub_maps_request
        allow(Geocoder::Search).to receive(:call).and_return(
          OpenStruct.new(coordinates: [ 14.350231, 51.648438 ])
        )
        allow(SchoolsQuery).to receive(:call).and_return(schools)
      end

      it "creates a placement request per school within the selected location" do
        expect { broadcast_to_schools }.to change { provider.placement_requests.count }.by(5)
      end

      context "when the provider has made another request to a school within a week" do
        before do
          create(:placement_request, school: schools.first, provider: provider)
        end

        it "creates a placement request only for schools without existing not sent requests" do
          expect { broadcast_to_schools }.to change { provider.placement_requests.count }.by(4)
        end
      end

      context "when another placement request has been recently sent to the a school" do
        before do
          create(:placement_request, :sent, school: schools.first, provider: provider)
        end

        it "creates a placement request only for schools not recently sent a placement request" do
          expect { broadcast_to_schools }.to change { provider.placement_requests.count }.by(4)
        end
      end

      context "when another placement request has been recently sent to the a school over a week ago" do
        before do
          create(:placement_request, :sent, school: schools.first, provider: provider, sent_at: 1.week.ago - 1.hour)
        end

        it "creates a placement request only for schools not recently sent a placement request" do
          expect { broadcast_to_schools }.to change { provider.placement_requests.count }.by(5)
        end
      end
    end

    context "when a step is not valid" do
      it "returns an error" do
        expect { broadcast_to_schools }.to raise_error "Invalid wizard state"
      end
    end
  end

  describe "#schools" do
    subject(:school_results) { wizard.schools }

    let(:schools) { create_list(:school, 5) }

    before do
      stub_maps_request
      allow(Geocoder::Search).to receive(:call).and_return(
        OpenStruct.new(coordinates: [ 14.350231, 51.648438 ])
      )
      allow(SchoolsQuery).to receive(:call).and_return(schools)
    end

    it "returns the schools within a certain radius and location" do
      expect(school_results).to eq(schools)
    end
  end

  describe "#location" do
    subject(:location) { wizard.location }

    let(:state) do
      {
        "location_search" => { "location" => "London", "radius" => 5 }
      }
    end

    it "returns the locations set in the location search step" do
      expect(location).to eq("London")
    end
  end

  describe "#radius" do
    subject(:radius) { wizard.radius }

    let(:state) do
      {
        "location_search" => { "location" => "London", "radius" => 5 }
      }
    end

    it "returns the radius set in the location search step" do
      expect(radius).to eq(5)
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
