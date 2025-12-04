class AcademicYearDecorator < ApplicationDecorator
  delegate_all

  def short_name
    "#{starts_on.year}/#{ends_on.strftime("%y")}"
  end

  def shortest_name
    "#{starts_on.strftime("%y")}/#{ends_on.strftime("%y")}"
  end

  def shortest_name_anchor
    shortest_name.parameterize
  end
end
