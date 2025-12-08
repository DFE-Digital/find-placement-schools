require "rails_helper"

describe SchoolsQuery do
  subject(:query) { described_class.new(params:) }

  let(:academic_year_id) { AcademicYear.current.id }
  let(:params) { { filters: { academic_year_id: } } }

  let!(:maths) { create(:placement_subject, name: "Mathematics", code: "MAT", phase: "secondary") }
  let!(:biology) { create(:placement_subject, name: "Biology", code: "BIO", phase: "secondary") }
  let!(:science) { create(:placement_subject, name: "Science", code: "SCI", phase: "secondary") }

  let(:query_school) do
    create(
      :school,
      name: "London Primary School",
      phase: "All-through",
      latitude: 51.648438,
      longitude: 14.350231,
      placement_preferences: [ build(:placement_preference, appetite: "actively_looking", academic_year: AcademicYear.current, placement_details: {
            "phase" => {
              "phases" => %w[primary send]
            },
            "secondary_subject_selection" => {
              "subject_ids" => [ maths.id, biology.id ]
            }
      }) ],
      organisation_address: build(:organisation_address, postcode: "LS1 2HE")
    )
  end

  let(:non_query_school) do
    create(:school, name: "York Secondary School", latitude: 29.732613, longitude: 105.448063)
  end


  before do
    query_school
    non_query_school
  end

  describe "#call" do
    it "returns all schools" do
      expect(query.call).to include(query_school)
      expect(query.call).to include(non_query_school)
    end

    context "when filtering by schools to show" do
      context "when filtering by offering placements" do
        let(:params) { { filters: { academic_year_id:, schools_to_show: [ "actively_looking" ] } } }

        it "returns the school offering placements" do
          expect(query.call).to include(query_school)
          expect(query.call).not_to include(non_query_school)
        end
      end

      context "when filtering by potentially offering placements" do
        let(:params) { { filters: { academic_year_id:, schools_to_show: [ "interested" ] } } }
        let(:interested_school) do
          create(
            :school,
            name: "Camden Primary School",
            phase: "All-through",
            placement_preferences: [ build(:placement_preference, appetite: "interested", academic_year: AcademicYear.current) ],
          )
        end

        before do
          interested_school
        end

        it "returns the interested school" do
          expect(query.call).to include(interested_school)
          expect(query.call).not_to include(query_school)
          expect(query.call).not_to include(non_query_school)
        end
      end

      context "when filtering by previously hosted placements" do
        let(:params) { { filters: { academic_year_id:, schools_to_show: [ "previously_hosted" ] } } }

        let(:previously_hosted_school) do
          create(
            :school,
            name: "Brixton Primary School",
            phase: "All-through",
            previous_placements: [ build(:previous_placement, placement_subject: PlacementSubject.first, academic_year: AcademicYear.previous) ],
            )
        end

        let(:same_year_previous_school) do
          create(
            :school,
            name: "Not Previously Hosted School",
            phase: "All-through",
            previous_placements: [ build(:previous_placement, placement_subject: PlacementSubject.first, academic_year: AcademicYear.current) ],
            )
        end

        before do
          previously_hosted_school
          same_year_previous_school
          create(:previous_placement, school: query_school, academic_year: AcademicYear.next)
        end

        it "returns only schools with previous placements in earlier academic years" do
          expect(query.call).to include(previously_hosted_school)
          expect(query.call).not_to include(same_year_previous_school)
          expect(query.call).not_to include(query_school)
          expect(query.call).not_to include(non_query_school)
        end
      end

      context "when filtering with multiple schools to show" do
        let(:params) { { filters: { academic_year_id:, schools_to_show: [ "actively_looking", "previously_hosted" ] } } }

        let(:previously_hosted_school) do
          create(
            :school,
            name: "Brixton Primary School",
            phase: "All-through",
            previous_placements: [ build(:previous_placement, placement_subject: PlacementSubject.first, academic_year: AcademicYear.previous) ],
          )
        end

        before do
          previously_hosted_school
          create(:previous_placement, school: query_school, academic_year: AcademicYear.next)
        end

        it "returns schools matching any of the selected 'schools to show'" do
          expect(query.call).to include(query_school)
          expect(query.call).to include(previously_hosted_school)
          expect(query.call).not_to include(non_query_school)
        end
      end
    end

    context "when filtering by name" do
      context "when a name is provided" do
        let(:params) { { filters: { academic_year_id:, search_by_name: "London" } } }

        it "returns the filtered schools" do
          expect(query.call).to include(query_school)
          expect(query.call).not_to include(non_query_school)
        end
      end

      context "when a urn is provided" do
        let(:params) { { filters: { search_by_name: query_school.urn } } }

        it "returns the filtered schools" do
          expect(query.call).to include(query_school)
          expect(query.call).not_to include(non_query_school)
        end
      end

      context "when a postcode is provided" do
        let(:params) { { filters: { search_by_name: "LS1 2HE" } } }

        it "returns the filtered schools" do
          expect(query.call).to include(query_school)
          expect(query.call).not_to include(non_query_school)
        end
      end

      context "when a mixed case postcode is provided" do
        let(:params) { { filters: { search_by_name: "LS1 2he" } } }

        it "returns the filtered schools" do
          expect(query.call).to include(query_school)
          expect(query.call).not_to include(non_query_school)
        end
      end

      context "when a partial postcode is provided" do
        let(:params) { { filters: { search_by_name: "LS1" } } }

        it "returns the filtered schools" do
          expect(query.call).to include(query_school)
          expect(query.call).not_to include(non_query_school)
        end
      end
    end

    context "when filtering by phase" do
      context "when filtering by primary" do
        let(:params) { { filters: { academic_year_id:, phases: [ "primary" ] } } }

        it "returns the filtered schools" do
          expect(query.call).to include(query_school)
          expect(query.call).not_to include(non_query_school)
        end
      end

      context "when filtering by secondary" do
        let(:params) { { filters: { academic_year_id:, phases: [ "secondary" ] } } }

        it "returns the filtered schools" do
          expect(query.call).not_to include(query_school)
          expect(query.call).not_to include(non_query_school)
        end
      end

      context "when filtering by SEND phase" do
        let(:params) { { filters: { academic_year_id:, phases: [ "send" ] } } }

        it "returns the filtered schools" do
          expect(query.call).to include(query_school)
          expect(query.call).not_to include(non_query_school)
        end
      end
    end

    context "when filtering by location" do
      let!(:close_query_school) do
        create(
          :school,
          name: "Bob's Primary School",
          phase: "Primary",
          latitude: 51.651101,
          longitude: 14.347458,
        )
      end

      let!(:far_query_school) do
        create(
          :school,
          name: "Jeff's Primary School",
          phase: "Primary",
          latitude: 51.654505,
          longitude: 14.319858,
        )
      end

      let(:location_coordinates) { [ query_school.latitude, query_school.longitude ] }
      let(:params) { { location_coordinates:, filters: { academic_year_id: } } }

      it "returns the filtered schools in order of distance" do
        expect(query.call).to eq([ query_school, close_query_school, far_query_school ])
        expect(query.call).not_to include(non_query_school)
      end

      context "when specifying a max distance" do
        let(:params) { { location_coordinates:, filters: { academic_year_id:, search_distance: 1 } } }

        it "returns the filtered schools in order of distance" do
          expect(query.call).to contain_exactly(query_school, close_query_school)
        end
      end
    end

    context "when filtering by subjects" do
      context "when filtering by a subject" do
        let(:params) { { filters: { academic_year_id:, subject_ids: [ maths.id ] } } }
        it "returns schools that have that subject in their placement preferences" do
          expect(query.call).to contain_exactly(query_school)
        end
      end

      context "when filtering by multiple subjects (ALL match)" do
        let(:params) { { filters: { academic_year_id:, subject_ids: [ maths.id, biology.id ] } } }
        it "returns schools that have that subject in their placement preferences" do
          expect(query.call).to contain_exactly(query_school)
        end
      end

      context "when filtering by multiple subject ids (ANY match)" do
        let(:params) { { filters: { academic_year_id:, subject_ids: [ science.id, biology.id ] } } }

        it "returns schools that match any of the selected subjects" do
          expect(query.call).to contain_exactly(query_school)
        end
      end
    end
  end
end
