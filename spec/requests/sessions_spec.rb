require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "GET /auth/dfe/callback" do
    after { OmniAuth.config.mock_auth[:dfe] = nil }

    it "signs the user in and redirects to root" do
      user = create(:user, dfe_sign_in_uid: "123", email_address: "user@example.com")

      # simulate the OmniAuth payload
      omniauth_hash = {
        "provider" => "dfe",
        "uid" => user.dfe_sign_in_uid,
        "info" => {
          "email" => user.email_address,
          "first_name" => user.first_name,
          "last_name" => user.last_name
        },
        "credentials" => {
          "id_token" => "abc"
        }
      }

      OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(omniauth_hash)

      get "/auth/dfe/callback"

      follow_redirect!

      expect(response).to have_http_status(:success)
      expect(response).to render_template("change_organisation/index")
      expect(session["dfe_sign_in_user"]).not_to be_nil
      expect(user.reload.last_signed_in_at).not_to be_nil
    ensure
      OmniAuth.config.mock_auth[:dfe] = nil
    end
  end

  describe "GET /auth/failure" do
    it "redirects to internal server error page" do
      get "/auth/failure", params: { message: "access_denied" }

      follow_redirect!

      expect(response).to have_http_status(:internal_server_error)

      expect(response).to render_template("errors/internal_server_error")
    end
  end
end
