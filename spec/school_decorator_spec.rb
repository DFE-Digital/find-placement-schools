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

        expect(school.decorate.percentage_free_school_meals_percentage).to be_nil
      end
    end
  end
end
