class AddAdminUserWizard < BaseWizard
  delegate :first_name, :last_name, :email_address, to: :user, allow_nil: true, prefix: true

  def define_steps
    add_step(AdminUserStep)
    add_step(CheckYourAnswersStep)
  end

  def create_user
    raise "Invalid wizard state" unless valid?

    user.save!
    user
  end

  private

  def user
    steps[:admin_user].admin_user
  end
end
