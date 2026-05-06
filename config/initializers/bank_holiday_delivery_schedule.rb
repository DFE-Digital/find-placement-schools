module BankHolidayDeliverySchedule
  def deliver_later(options = {})
    return super(options) unless BankHoliday.is_bank_holiday?(Date.current)

    next_working_day = BankHoliday.next_working_day(Date.current)

    Rails.logger.info "Email rescheduled because today is a bank holiday."
    super(options.merge(wait_until: next_working_day.beginning_of_day))
  end
end

ActionMailer::MessageDelivery.prepend(BankHolidayDeliverySchedule)
