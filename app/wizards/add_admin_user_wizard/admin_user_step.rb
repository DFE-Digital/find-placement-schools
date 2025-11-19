class AddAdminUserWizard::AdminUserStep < BaseStep
  attribute :first_name
  attribute :last_name
  attribute :email_address

  SUPPORT_EMAIL_REGEXP = /\A[a-zA-Z0-9.!\#$%&'*+\/=?^_`{|}~-]+@education.gov.uk\z/

  validates :first_name, :last_name, presence: true
  validates :email_address, presence: true, format: { with: SUPPORT_EMAIL_REGEXP, message: :invalid_support_email }
  validate :new_admin_user

  def new_admin_user
    return if User.where(admin: true).find_by(email_address:).blank?

    errors.add(:email_address, :taken)
  end

  def admin_user
    @admin_user ||= User.find_or_initialize_by(email_address:).tap do |user|
      user.assign_attributes(first_name:, last_name:, admin: true)
    end
  end
end
