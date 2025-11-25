class Admin::ChangeOrganisationController < AdminController
  def provider_organisations
    organisations = ProvidersQuery.call(params: filter_params_hash)
    pagy, organisations = pagy(organisations)
    render locals: { pagy:, providers: organisations, filter_params: filter_params_hash }
  end

  def school_organisations
    organisations = SchoolsQuery.call(params: filter_params_hash)
    pagy, organisations = pagy(organisations)
    render locals: { pagy:, schools: organisations, filter_params: filter_params_hash }
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

  def search_by_name_param
    params.fetch(:search_by_name, "").to_s.strip.presence
  end

  def filter_params_hash
    { filters: { search_by_name: search_by_name_param || "" } }
  end
end
