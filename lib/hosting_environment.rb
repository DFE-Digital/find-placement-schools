module HostingEnvironment
  def self.env
    @env ||= ActiveSupport::EnvironmentInquirer.new(ENV["RAILS_ENV"].presence || "development")
  end
end
