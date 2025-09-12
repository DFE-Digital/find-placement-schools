module UnknownOptionable
  extend ActiveSupport::Concern

  def unknown_option
    @unknown_option ||=
      OpenStruct.new(
        value: AddHostingInterestWizard::UNKNOWN_OPTION,
        name: I18n.t(
          "wizards.add_hosting_interest_wizard.unknown",
          ),
        )
  end
end
