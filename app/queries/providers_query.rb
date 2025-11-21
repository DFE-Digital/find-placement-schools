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

    scope.where("organisations.name ILIKE ?", "%#{filter_params[:search_by_name]}%")
         .or(scope.where("urn ILIKE ?", "%#{filter_params[:search_by_name]}%"))
  end

  def order_condition(scope)
    scope.distinct.order(:name)
  end
end
