class BroadcastPlacementRequests < ApplicationService
  def call
    not_sent_requests =  PlacementRequest.not_sent
    schools = School.where(
      id: not_sent_requests.pluck(:school_id).uniq,
    )

    NotifyRateLimiter.call(
      collection: schools,
      mailer: "SchoolMailer",
      mailer_method: :placement_request_notification,
    )

    not_sent_requests.find_each do |request|
      request.update!(sent_at: DateTime.now)
    end
  end
end
