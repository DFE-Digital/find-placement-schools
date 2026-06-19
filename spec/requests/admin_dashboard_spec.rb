require "rails_helper"

RSpec.describe "AdminDashboard", type: :request do
  describe "GET /admin_dashboard/build_development_seed_data" do
    before do
      allow(HostingEnvironment.env).to receive(:az_development?).and_return(false)
    end

    context "when in development" do
      before do
        allow(Rails.env).to receive(:development?).and_return(true)
        allow(DevelopmentSeedData).to receive(:call)
        post development_access_path, params: {
          development_access: {
            password: "bat"
          }
        }
        sign_in_admin_user
      end

      it "builds the development seed data and redirects to the dashboard" do
        get build_development_seed_data_admin_dashboard_index_path

        expect(DevelopmentSeedData).to have_received(:call).once
        expect(response).to redirect_to(admin_dashboard_index_path)
        expect(flash[:heading]).to eq("Development seed data built")
        expect(flash[:success]).to eq(true)
      end
    end

    context "when in az development" do
      before do
        allow(Rails.env).to receive(:development?).and_return(false)
        allow(HostingEnvironment.env).to receive(:az_development?).and_return(true)
        allow(DevelopmentSeedData).to receive(:call)
        post development_access_path, params: {
          development_access: {
            password: "bat"
          }
        }
        sign_in_admin_user
      end

      it "builds the development seed data and redirects to the dashboard" do
        get build_development_seed_data_admin_dashboard_index_path

        expect(response).to redirect_to(admin_dashboard_index_path)
        expect(DevelopmentSeedData).to have_received(:call).once
      end
    end

    context "when not in development" do
      before do
        allow(Rails.env).to receive(:development?).and_return(false)
        allow(DevelopmentSeedData).to receive(:call)
        sign_in_admin_user
      end

      it "returns not found" do
        get build_development_seed_data_admin_dashboard_index_path

        expect(response).to have_http_status(:not_found)
        expect(DevelopmentSeedData).not_to have_received(:call)
      end
    end
  end
end
