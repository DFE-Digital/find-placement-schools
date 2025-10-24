class OnboardUsersWizard::UserTypeStep < BaseStep
  attribute :user_type, :string

  USER_TYPES = %w[school provider].freeze

  validates :user_type, presence: true, inclusion: { in: USER_TYPES }

  def user_type_options
    options = Struct.new(:value, :name)
    USER_TYPES.map do |key|
      options.new(
        value: key,
        name: I18n.t(
          "#{locale_path}.options.#{key}",
          ),
        )
    end
  end

  private

  def locale_path
    "wizards.onboard_users_wizard.user_type_step"
  end
end
