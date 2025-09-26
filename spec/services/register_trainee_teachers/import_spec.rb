require "rails_helper"

RSpec.describe RegisterTraineeTeachers::Import do
  let(:school) { create(:school) }
  let(:another_school) { create(:school) }
  let(:academic_year) { create(:academic_year, :current) }
  let(:placement_subject) { create(:placement_subject) }
  let(:csv_data) do
    [
      {
       school_id: school.id,
       academic_year_id: academic_year.id,
       subject_id: placement_subject.id,
       number_of_placements: 5
      },
      {
        school_id: another_school.id,
        academic_year_id: academic_year.id,
        subject_id: placement_subject.id,
        number_of_placements: 2
      }
    ]
  end

  describe "#call" do
    subject(:call) { described_class.call(csv_data:) }

    context "when no previous placements exist" do
      it "creates a previous placement record per row of CSV data" do
        expect { call }.to change(PreviousPlacement, :count).by(2)
      end
    end

    context "when previous placements exist" do
      let!(:existing_previous_placement) do
        create(
          :previous_placement,
          academic_year:,
          school:,
          placement_subject:,
          number_of_placements: 1,
          )
      end

      it "updates the existing previous placement" do
        expect { call }.to change(PreviousPlacement, :count).by(1)
        existing_previous_placement.reload
        expect(existing_previous_placement.number_of_placements).to eq(5)
      end
    end
  end
end
