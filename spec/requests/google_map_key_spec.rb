require "rails_helper"

RSpec.describe "Google map key", type: :request do
  before { sign_in_user }
  after { OmniAuth.config.mock_auth[:dfe] = nil }

  describe "GET /api/google/map-key" do
    it "returns the Google Maps API key" do
      ClimateControl.modify GOOGLE_MAPS_API_KEY: "test-google-maps-api-key" do
        get google_map_key_path

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq("map_key" => "test-google-maps-api-key")
      end
    end

    it "returns an error when the Google Maps API key is not configured" do
      ClimateControl.modify GOOGLE_MAPS_API_KEY: nil do
        get google_map_key_path

        expect(response).to have_http_status(:internal_server_error)
        expect(JSON.parse(response.body)).to eq("error" => "Google Maps API key not configured")
      end
    end
  end
end
