class Admin::ChangeOrganisationController < AdminController
  def provider_organisations
    organisations = params[:name].present? ? Provider.where("name ILIKE ?", "%#{params[:name]}%") : Provider
    pagy, organisations = pagy(organisations.order(:name))
    render locals: { pagy:, providers: organisations, filter_params: }
  end

  def school_organisations
    organisations = params[:name].present? ? School.where("name ILIKE ?", "%#{params[:name]}%") : School
    pagy, organisations = pagy(organisations.order(:name))
    render locals: { pagy:, schools: organisations, filter_params: }
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

  def filter_params
    params.fetch(:filters, []).compact.reject(&:blank?)
  end
end
