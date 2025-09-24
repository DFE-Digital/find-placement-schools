module HostingEnvironment
  def self.env
    @env ||= ActiveSupport::EnvironmentInquirer.new(ENV["HOSTING_ENV"].presence || "development")
  end
end
