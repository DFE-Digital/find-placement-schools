require "rails_helper"

RSpec.describe GIAS::CSVImporter do
  subject(:gias_importer) { described_class.call(csv_path) }

  let(:csv_path) { "spec/fixtures/gias/gias_subset_transformed.csv" }

  it_behaves_like "a service object" do
    let(:params) { { csv_path: } }
  end

  it "creates new schools" do
    expect { gias_importer }.to change(School, :count).from(0).to(5)
  end

  it "updates existing schools" do
    school = create(:organisation, :school, urn: "100000", name: "The wrong name")
    expect { gias_importer }.to change { school.reload.name }.to "The Aldgate School"
  end

  it "logs messages to STDOUT" do
    expect(Rails.logger).to receive(:info).with("GIAS Data Imported!")
    expect(Rails.logger).to receive(:info).with("Deleted schools which have been closed from the database.")

    gias_importer
  end

  describe "associating schools with addresses" do
    let(:csv_path) { "spec/fixtures/gias/gias_subset_transformed.csv" }

    context "when an address is associated with a school" do
      it "updates the address" do
        organisation_address = build(:organisation_address, address_1: "Old Street", town: "Old Town", postcode: "NEW1 1AA")
        school = create(:organisation, :school, urn: "100000", organisation_address:)

        expect { gias_importer }.to change { school.reload.organisation_address.address_1 }.to("St James's Passage")
      end
    end

    context "when a school does not have an address" do
      it "creates a new address" do
        school = create(:organisation, :school, urn: "100000")

        expect { gias_importer }.to change { school.reload.organisation_address }.from(nil).to(be_a(OrganisationAddress))
      end
    end
  end

  context "when URN is not present" do
    let(:csv_path) { "spec/fixtures/gias/gias_subset_transformed_without_urns.csv" }

    it "does not create a school" do
      expect { gias_importer }.not_to change(School, :count)
    end
  end

  describe "geocoding schools" do
    subject(:school) { School.find_by!(urn:) }

    before { gias_importer }

    context "when the CSV has a Latitude/Longitude for the school" do
      let(:urn) { "100000" }

      it "geocodes the school" do
        expect(school).to be_geocoded
        expect(school.latitude).to eq(51.5139702631)
        expect(school.longitude).to eq(-0.0775045667)
      end
    end

    context "when the CSV doesn't provide a Latitude/Longitude for the school" do
      let(:csv_path) { "spec/fixtures/gias/gias_subset_transformed_without_lat_lng.csv" }
      let(:urn) { "100000" }

      it "imports the school but does not geocode it" do
        expect(school).not_to be_geocoded
        expect(school.latitude).to be_nil
        expect(school.longitude).to be_nil
      end
    end
  end

  describe "Removing schools that have been closed" do
    context "when the school has no placement preferences" do
      let(:school) { create(:organisation, :school, urn: "999") }

      before { school }

      it "is removed from the database" do
        expect { gias_importer }.to change { School.exists?(id: school.id) }.from(true).to(false)
      end
    end

    context "when the school has placement preferences" do
      let(:school) { build(:organisation, :school, urn: "999") }

      before do
        create(:placement_preference, :actively_looking, organisation: school)
      end

      it "is not removed from the database" do
        expect { gias_importer }.not_to change { School.exists?(id: school.id) }.from(true)
      end
    end

    context "when the school has not been closed" do
      let(:school) { create(:organisation, :school, urn: "100000") }

      it "is not removed from the database" do
        expect { gias_importer }.not_to change { School.exists?(id: school.id) }.from(true)
      end
    end
  end
end
