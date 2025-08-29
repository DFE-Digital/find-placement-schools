class UrgentPlacementBroadcastWizard < BaseWizard
  attr_reader :provider, :current_user
  def initialize(current_user:, provider:, params:, state:, current_step: nil)
    @provider = provider
    @current_user = current_user
    super(state:, params:, current_step:)
  end

  def define_steps
    # Define the wizard steps here
    add_step(LocationSearchStep)
    add_step(SchoolResultsStep)
  end

  def broadcast_to_schools
    raise "Invalid wizard state" unless valid?

    ApplicationRecord.transaction do
      schools = steps.fetch(:school_results).schools
      schools.each do |school|
        next if PlacementRequest
          .sent.where(school: school, provider: provider)
          .where("sent_at > ?", 1.week.ago).present?

        PlacementRequest.find_or_create_by!(
          school: school, provider: provider, sent_at: nil
        ) do |request|
          request.requested_by = current_user
        end
      end
    end
  end

  def schools
    @schools ||= steps.fetch(:school_results).schools
  end

  def location
    @location ||= steps.fetch(:location_search).location
  end

  def radius
    @radius ||= steps.fetch(:location_search).radius
  end
end
