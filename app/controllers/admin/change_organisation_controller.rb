class Admin::ChangeOrganisationController < AdminController
  def provider_organisations
    @pagy, @organisations = pagy(Provider.order(:name))
    render locals: { pagy: @pagy, providers: @organisations }
  end

  def school_organisations
    @pagy, @organisations = pagy(School.order(:name))
    render locals: { pagy: @pagy, schools: @organisations }
  end

  def update_organisation
    selected_organisation = Organisation.find(params[:organisation_id])
    current_user.update(selected_organisation:)

    redirect_to change_organisation_update_organisation_path(change_organisation_id: selected_organisation.id)
  end

  def return_to_dashboard
    current_user.update(selected_organisation: nil)
    redirect_to admin_dashboard_index_path
  end
end
