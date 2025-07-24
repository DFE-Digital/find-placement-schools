class OrganisationsController < ApplicationController
  def show
    @organisation = Organisation.find(params[:id])

    render locals: { organisation: @organisation }
  end

  def index
    @pagy, @schools = pagy(School.all)

    render locals: { pagy: @pagy, schools: @schools.decorate }
  end
end
