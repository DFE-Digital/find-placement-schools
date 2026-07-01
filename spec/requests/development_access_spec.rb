require "rails_helper"

RSpec.describe "DevelopmentAccess", type: :request do
  describe "development password protection" do
    before do
      allow(Rails.env).to receive(:development?).and_return(true)
    end

    it "redirects GET requests to the development access page until unlocked" do
      get "/"

      expect(response).to redirect_to(new_development_access_path)
      expect(session["requested_path_after_development_access"]).to eq("/")
    end

    it "stores the path for HEAD requests too" do
      head "/"

      expect(response).to redirect_to(new_development_access_path)
      expect(session["requested_path_after_development_access"]).to eq("/")
    end

    it "allows access to the development access page" do
      get new_development_access_path

      expect(response).to have_http_status(:success)
    end

    it "unlocks access with the correct password" do
      get "/organisations"

      post development_access_path, params: {
        development_access: {
          password: "bat"
        }
      }

      expect(session["development_access_granted"]).to eq(true)
      expect(response).to redirect_to("/organisations")
    end

    it "does not unlock access with an incorrect password" do
      post development_access_path, params: {
        development_access: {
          password: "wrong"
        }
      }

      expect(session["development_access_granted"]).to be_nil
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Development access")
    end
  end

  describe "in non-development environments" do
    it "does not enforce development password protection" do
      get "/"

      expect(response).to have_http_status(:success)
    end
  end
end
