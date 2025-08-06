require "rails_helper"

describe DfeSignInUser do
  describe ".begin_session!" do
    it "creates a new session with DfE user details" do
      Timecop.freeze do
        session = {}
        omniauth_payload = {
          "info" => {
            "first_name" => "Example",
            "last_name" => "User",
            "email" => "example_user@example.com"
          },
          "uid" => "123",
          "credentials" => { "id_token" => "abc" },
          "provider" => "dfe"
        }

        described_class.begin_session!(session, omniauth_payload)

        expect(session).to eq(
          "dfe_sign_in_user" => {
            "first_name" => "Example",
            "last_name" => "User",
            "email_address" => "example_user@example.com",
            "dfe_sign_in_uid" => "123",
            "last_active_at" => Time.current,
            "id_token" => "abc",
            "provider" => "dfe"
          }
        )
      end
    end
  end

  describe ".load_from_session" do
    it "returns a DfeSignInUser with details from the session" do
      session = {
        "dfe_sign_in_user" => {
          "first_name" => "Example",
          "last_name" => "User",
          "email_address" => "example_user@example.com",
          "last_active_at" => 1.hour.ago,
          "dfe_sign_in_uid" => "123",
          "id_token" => "abc",
          "provider" => "dfe"
        }
      }

      dfe_sign_in_user = described_class.load_from_session(session)

      expect(dfe_sign_in_user).not_to be_nil
      expect(dfe_sign_in_user.first_name).to eq("Example")
      expect(dfe_sign_in_user.last_name).to eq("User")
      expect(dfe_sign_in_user.email_address).to eq("example_user@example.com")
      expect(dfe_sign_in_user.dfe_sign_in_uid).to eq("123")
      expect(dfe_sign_in_user.id_token).to eq("abc")
      expect(dfe_sign_in_user.provider).to eq("dfe")
    end

    it "returns nil if session is expired" do
      session = {
        "dfe_sign_in_user" => {
          "last_active_at" => 3.hours.ago
        }
      }

      expect(described_class.load_from_session(session)).to be_nil
    end
  end

  describe "#logout_url" do
    let(:request) { instance_double(ActionDispatch::Request, base_url: "https://myapp.example.com") }

    it "returns DfE logout URL when signed in via DfE" do
      session = {
        "dfe_sign_in_user" => {
          "first_name" => "Example",
          "last_name" => "User",
          "email_address" => "example_user@example.com",
          "last_active_at" => 1.hour.ago,
          "dfe_sign_in_uid" => "123",
          "id_token" => "abc",
          "provider" => "dfe"
        }
      }

      user = described_class.load_from_session(session)
      expect(user.logout_url(request)).to include("session/end")
      expect(user.logout_url(request)).to include("id_token_hint=abc")
      expect(user.logout_url(request)).to include("post_logout_redirect_uri=")
    end

    it "returns developer logout path if not DfE" do
      session = {
        "dfe_sign_in_user" => {
          "first_name" => "Example",
          "last_name" => "User",
          "email_address" => "example_user@example.com",
          "last_active_at" => 1.hour.ago,
          "dfe_sign_in_uid" => "123",
          "id_token" => "abc",
          "provider" => nil
        }
      }

      user = described_class.load_from_session(session)
      expect(user.logout_url(request)).to eq("/auth/developer/sign-out")
    end
  end

  describe "#user" do
    it "finds a User by dfe_sign_in_uid" do
      db_user = create(:user, dfe_sign_in_uid: "11111111-2222-3333-4444-555555555555", email_address: "user@example.com")

      session = {
        "dfe_sign_in_user" => {
          "first_name" => db_user.first_name,
          "last_name" => db_user.last_name,
          "email_address" => "not_matching@example.com",
          "last_active_at" => 1.hour.ago,
          "dfe_sign_in_uid" => "11111111-2222-3333-4444-555555555555",
          "id_token" => "abc",
          "provider" => "dfe"
        }
      }

      dfe_user = described_class.load_from_session(session)
      expect(dfe_user.user).to eq(db_user)
    end

    it "finds a User by email_address if dfe_sign_in_uid is not present" do
      db_user = create(:user, dfe_sign_in_uid: nil, email_address: "user@example.com")

      session = {
        "dfe_sign_in_user" => {
          "first_name" => db_user.first_name,
          "last_name" => db_user.last_name,
          "email_address" => "user@example.com",
          "last_active_at" => 1.hour.ago,
          "dfe_sign_in_uid" => nil,
          "id_token" => "abc",
          "provider" => "dfe"
        }
      }

      dfe_user = described_class.load_from_session(session)
      expect(dfe_user.user).to eq(db_user)
    end

    it "returns nil if no matching User exists" do
      session = {
        "dfe_sign_in_user" => {
          "first_name" => "No",
          "last_name" => "User",
          "email_address" => "noone@example.com",
          "last_active_at" => 1.hour.ago,
          "dfe_sign_in_uid" => "999",
          "id_token" => "abc",
          "provider" => "dfe"
        }
      }

      dfe_user = described_class.load_from_session(session)
      expect(dfe_user.user).to be_nil
    end
  end

  describe ".end_session!" do
    it "clears the session" do
      session = {
        "dfe_sign_in_user" => {
          "first_name" => "Example",
          "last_name" => "User",
          "email_address" => "example_user@example.com",
          "last_active_at" => 1.hour.ago,
          "dfe_sign_in_uid" => "123",
          "id_token" => "abc",
          "provider" => "dfe"
        }
      }

      described_class.end_session!(session)

      expect(session).to eq({})
    end
  end
end
