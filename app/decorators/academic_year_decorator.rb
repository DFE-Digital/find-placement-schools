class AcademicYearDecorator < ApplicationDecorator
  delegate_all

  def short_name
    "#{starts_on.year}/#{ends_on.strftime("%y")}"
  end
end
