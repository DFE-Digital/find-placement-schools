require "rails_helper"

RSpec.describe SchoolDecorator do
  describe "#formatted_address" do
    it "returns a formatted address" do
      organisation_address = build(:organisation_address,
          address_1: "A School",
          address_2: "The School Road",
          address_3: "Somewhere",
          town: "London",
          postcode: "LN12 1LN",
        )
      school = build(:school, organisation_address:)


      expect(school.decorate.formatted_address).to eq(
        "<p>A School, The School Road, Somewhere, London, LN12 1LN</p>",
      )
    end

    context "when attributes are missing" do
      it "returns a formatted address based on the present attributes" do
        organisation_address = build(:organisation_address,
                                     address_1: "A School",
                                     address_2: "The School Road",
                                     address_3: "Somewhere",
                                     postcode: "LN12 1LN"
                                     )
        school = build(:school, organisation_address:)

        expect(school.decorate.formatted_address).to eq(
          "<p>A School, The School Road, Somewhere, LN12 1LN</p>",
        )
      end
    end

    context "when all address attributes are missing" do
      it "returns nil" do
        school = create(:school)
        expect(school.decorate.formatted_address).to be_nil
      end
    end
  end

  describe "#formatted_inspection_date" do
    it "returns nicely formatted date" do
      school = build(:school, last_inspection_date: Date.new(2020, 10, 12))

      expect(school.decorate.formatted_inspection_date).to eq("12 October 2020")
    end
  end

  describe "#age_range" do
    it "return the minimum age and maximum age as a sentence" do
      school = build(:school, minimum_age: 4, maximum_age: 11)

      expect(school.decorate.age_range).to eq("4 to 11")
    end
  end

  describe "#percentage_free_school_meals_percentage" do
    it "returns the percentage of free school meals" do
      school = build(:school, percentage_free_school_meals: 20)

      expect(school.decorate.percentage_free_school_meals_percentage).to eq("20%")
    end

    context "when the percentage is nil" do
      it "returns nil" do
        school = build(:school, percentage_free_school_meals: nil)

        expect(school.decorate.percentage_free_school_meals_percentage).to eq("Unknown")
      end
    end
  end

  describe "#previously_hosted_placements" do
    subject(:previously_hosted_placements) do
      school.decorate.previously_hosted_placements
    end

    let(:school) { create(:school) }

    context "when the school has not previously hosted placements" do
      it "returns nil" do
        expect(previously_hosted_placements).to be_nil
      end
    end

    context "when the school has previously hosted placements" do
      let(:last_academic_year) { AcademicYear.for_date(Time.now - 1.year) }
      let(:academic_year_2_years_ago) { AcademicYear.for_date(Time.now - 2.year) }
      let(:academic_year_3_years_ago) { AcademicYear.for_date(Time.now - 3.year) }
      let(:english) { create(:placement_subject, name: "English", code: "A1") }
      let(:maths) { create(:placement_subject, name: "Mathematics", code: "B2") }
      let(:science) { create(:placement_subject, name: "Science", code: "C3") }
      let(:english_previous_placement_ay1) do
        create(
          :previous_placement,
          placement_subject: english,
          academic_year: last_academic_year,
          school:,
      )
      end
      let(:science_previous_placement_ay1) do
        create(
          :previous_placement,
          placement_subject: science,
          academic_year: last_academic_year,
          school:,
        )
      end
      let(:maths_previous_placement_ay2) do
        create(
          :previous_placement,
          placement_subject: maths,
          academic_year: academic_year_2_years_ago,
          school:,
        )
      end
      let(:english_previous_placement_ay3) do
        create(
          :previous_placement,
          placement_subject: english,
          academic_year: academic_year_3_years_ago,
          school:,
        )
      end

      before do
        english_previous_placement_ay1
        science_previous_placement_ay1
        maths_previous_placement_ay2
        english_previous_placement_ay3
      end

      it "returns a hash of academic years and their previous placement subjects" do
        expect(previously_hosted_placements).to eq({
          last_academic_year.name => "English and Science",
          academic_year_2_years_ago.name => "Mathematics",
          academic_year_3_years_ago.name => "English"
        })
      end

      context "when there is a previous placement older than 3 years ago" do
        before do
          create(
            :previous_placement,
            placement_subject: english,
            academic_year: AcademicYear.for_date(Time.now - 4.years),
            school:,
          )
        end
        it "returns a hash only containing previous placements for the last 3 years" do
          expect(previously_hosted_placements).to eq({
            last_academic_year.name => "English and Science",
            academic_year_2_years_ago.name => "Mathematics",
            academic_year_3_years_ago.name => "English"
          })
        end
      end
    end
  end
end
