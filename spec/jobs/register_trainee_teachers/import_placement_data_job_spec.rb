require "rails_helper"

RSpec.describe RegisterTraineeTeachers::ImportPlacementDataJob, type: :job do
  let(:csv_data) do
    [ {
       school_id: create(:school).id,
       academic_year_id: create(:academic_year, :current).id,
       subject_id: create(:placement_subject).id,
       number_of_placements: 5
    } ]
  end

  describe "#perform" do
    before do
      allow(RegisterTraineeTeachers::Import).to receive(:call).and_return(true)
    end

    it "calls the RegisterTraineeTeachers::Import service" do
      described_class.perform_now(csv_data:)
      expect(RegisterTraineeTeachers::Import).to have_received(:call).with(
        csv_data:
      ).once
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later(csv_data:)
      }.to have_enqueued_job(described_class).on_queue("default")
    end
  end
end
