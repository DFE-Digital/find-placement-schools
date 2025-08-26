class BroadcastPlacementRequests
  def call
    schools = School.where(
      id: PlacementRequest.not_sent.pluck(:school_id).uniq,
    )

    schools.each do |school|
      # Send email
    end
  end
end