class ProvidersQuery < ApplicationQuery
  def call
    scope = Provider
    scope = search_by_name_condition(scope)
    order_condition(scope)
  end

  private

  def filter_params
    @filter_params ||= params.fetch(:filters, {})
  end

  def search_by_name_condition(scope)
    return scope if filter_params[:search_by_name].blank?

    term = "%#{filter_params[:search_by_name]}%"
    scope.left_outer_joins(:organisation_address)
         .where("organisations.name ILIKE ? OR organisations.ukprn ILIKE ? OR organisation_addresses.postcode ILIKE ?", term, term, term)
  end

  def order_condition(scope)
    scope.distinct.order(:name)
  end
end
