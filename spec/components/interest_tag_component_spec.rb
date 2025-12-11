require "rails_helper"

RSpec.describe InterestTagComponent, type: :component do
  subject(:component) do
    described_class.new(school:, academic_year:)
  end

  let(:academic_year) { AcademicYear.next }
  let(:school) { create(:school, placement_preferences:) }

  before do
    render_inline(component)
  end

  context "when the school is actively looking" do
    let(:placement_preferences) { [ build(:placement_preference, appetite: "actively_looking") ] }

    it "renders the correct text" do
      expect(page).to have_content "Offering placements"
    end

    it "renders the correct tag" do
      expect(page).to have_css(".govuk-tag--green")
    end
  end

  context "when the school is interested in hosting" do
    let(:placement_preferences) { [ build(:placement_preference, appetite: "interested") ] }

    it "renders the correct text" do
      expect(page).to have_content "Potentially offering placements"
    end

    it "renders the correct tag" do
      expect(page).to have_css(".govuk-tag--yellow")
    end
  end

  context "when the school is not open to hosting" do
    let(:placement_preferences) { [ build(:placement_preference, appetite: "not_open") ] }

    it "renders the correct text" do
      expect(page).to have_content "Not offering placements"
    end

    it "renders the correct tag" do
      expect(page).to have_css(".govuk-tag--red")
    end
  end

  context "when the school has not specified a placement preference" do
    let(:school) { create(:school) }

    it "renders the correct text" do
      expect(page).to have_content "Placement availability unknown"
    end

    it "renders the correct tag" do
      expect(page).to have_css(".govuk-tag--grey")
    end
  end

  context "when the school has previous offered placements" do
    let(:previous_placements) { [ build(:previous_placement, academic_year: AcademicYear.current) ] }
    let(:school) { create(:school, previous_placements:) }

    it "renders the correct text" do
      expect(page).to have_content "Previously hosted placements"
    end

    it "renders the correct tag" do
      expect(page).to have_css(".govuk-tag--blue")
    end
  end
end
