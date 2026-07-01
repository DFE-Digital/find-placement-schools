require "rails_helper"

RSpec.describe DevelopmentSeedData do
  it_behaves_like "a service object"

  describe ".call" do
    before do
      allow(HostingEnvironment.env).to receive(:az_development?).and_return(false)
      allow(GIAS::SyncAllSchoolsJob).to receive(:perform_now) do
        create(:school, phase: "Primary")
        create(:school, phase: "Secondary")
        create_list(:school, 100, phase: "Secondary")
      end
      allow(PublishTeacherTraining::Subject::Import).to receive(:call) do
        create_list(:placement_subject, 12, phase: :primary) if PlacementSubject.primary.none?
        create_list(:placement_subject, 24, :secondary) if PlacementSubject.secondary.none?
      end
    end

    context "when in development" do
      before do
        allow(Rails.env).to receive(:development?).and_return(true)
      end

      it "seeds development data and is idempotent" do
        create(:placement_preference)
        create(:previous_placement)
        create(:placement_subject, :secondary)

        expect {
          described_class.call
        }.to change(User, :count).by(PERSONAS.size)
         .and change(School, :count).by(102)
         .and change(Provider, :count).by(1)
         .and change(UserMembership, :count).by(4)
         .and change(PlacementSubject.secondary, :count).by(23)
         .and change(PlacementPreference, :count).by(89)
         .and change(PreviousPlacement, :count).by(179)

        expect(PlacementPreference.count).to eq(90)
        expect(PreviousPlacement.count).to eq(180)

        primary_school = School.find_by!(phase: "Primary")
        secondary_school = School.find_by!(phase: "Secondary")

        expect(primary_school.previous_placements.pluck(:subject_name)).to all(
          be_in(PlacementSubject.primary.order(:name).pluck(:name)),
        )
        expect(secondary_school.previous_placements.pluck(:subject_name)).to all(
          be_in(PlacementSubject.secondary.order(:name).pluck(:name)),
        )

        expect(GIAS::SyncAllSchoolsJob).to have_received(:perform_now).once

        placement_details = PlacementPreference.pluck(:placement_details)
        expect(placement_details).to include(a_hash_including("year_group_selection" => anything))
        expect(placement_details).to include(a_hash_including("key_stage_selection" => anything))
        expect(placement_details).to include(a_hash_including("secondary_subject_selection" => anything))

        first_school = School.order(:urn).first
        first_school_preference = first_school.placement_preference_for(academic_year: AcademicYear.current)
        expect(first_school_preference.created_by.first_name).to eq("Patricia")
        expect(first_school_preference.appetite).to eq("actively_looking")

        first_school_preference.update!(appetite: :not_open)

        expect {
          described_class.call
        }.to not_change(User, :count)
         .and not_change(School, :count)
         .and not_change(Provider, :count)
         .and not_change(UserMembership, :count)
         .and not_change(PlacementSubject.secondary, :count)
         .and not_change(PlacementPreference, :count)
         .and not_change(PreviousPlacement, :count)

        expect(first_school.placement_preference_for(academic_year: AcademicYear.current).appetite).to eq("actively_looking")
      end

      it "syncs schools when only a small subset already exists" do
        create_list(:school, 3)

        expect {
          described_class.call
        }.to change(School, :count).by(102)
         .and change(PlacementPreference, :count).by(90)

        expect(GIAS::SyncAllSchoolsJob).to have_received(:perform_now).once
      end
    end

    context "when in az development" do
      before do
        allow(Rails.env).to receive(:development?).and_return(false)
        allow(HostingEnvironment.env).to receive(:az_development?).and_return(true)
      end

      it "seeds development data" do
        expect {
          described_class.call
        }.to change(PlacementPreference, :count).by(90)
      end
    end

    context "when not in development" do
      before do
        allow(Rails.env).to receive(:development?).and_return(false)
      end

      it "does nothing" do
        expect {
          described_class.call
        }.to not_change(User, :count)
         .and not_change(School, :count)
         .and not_change(Provider, :count)
         .and not_change(UserMembership, :count)
         .and not_change(PlacementSubject, :count)
         .and not_change(PlacementPreference, :count)
         .and not_change(PreviousPlacement, :count)

        expect(GIAS::SyncAllSchoolsJob).not_to have_received(:perform_now)
        expect(PublishTeacherTraining::Subject::Import).not_to have_received(:call)
      end
    end
  end
end
