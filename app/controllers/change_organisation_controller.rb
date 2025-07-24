class ChangeOrganisationController < ApplicationController
  include OrganisationRedirectable

  def index
    @schools = current_user.organisations.where(type: "School")
    @providers = current_user.organisations.where(type: "Provider")

    render locals: { schools: @schools, providers: @providers }
  end

  def update_organisation
    redirect_to_organisation(current_user, params[:change_organisation_id])
  end
end
