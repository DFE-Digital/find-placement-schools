class AdminDashboardController < AdminController
  helper_method :development_seed_data_available?

  before_action :require_development_environment, only: :build_development_seed_data

  def index; end

  def build_development_seed_data
    DevelopmentSeedData.call

    redirect_to admin_dashboard_index_path, flash: {
      heading: "Development seed data built",
      body: "The development seed data is now available in the running service.",
      success: true
    }
  end

  private

  def require_development_environment
    head :not_found unless development_seed_data_available?
  end

  def development_seed_data_available?
    Rails.env.development? || HostingEnvironment.env.az_development?
  end
end
