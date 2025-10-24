require "rails_helper"

RSpec.describe Users::CreateCollectionJob, type: :job do
  describe "#perform" do
    let(:school) { create(:school) }
    let(:user_details) do
      [
        {
          organisation_id: school.id,
          first_name: "Joe",
          last_name: "Bloggs",
          email_address: "joe_bloggs@example.com"
        },
        {
          organisation_id: school.id,
          first_name: "Sue",
          last_name: "Doe",
          email_address: "sue_doe@example.com"
        }
      ]
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later(user_details:)
      }.to have_enqueued_job(described_class).on_queue("default")
    end

    context "when the array of user details is over 100 elements" do
      let(:user_details) do
        Array.new(125) do |i|
          { organisation_id: school.id,
            first_name: "Joe",
            last_name: "Bloggs",
            email_address: "joe_bloggs#{i}@example.com"
          }
        end
      end

      before do
        allow(Users::Invite).to receive(:call).with(hash_including(wait_time: 0.minutes)).exactly(100).times
        allow(Users::Invite).to receive(:call).with(hash_including(wait_time: 1.minute)).exactly(25).times
      end

      it "delays sending the emails" do
        described_class.perform_now(user_details:)

        expect(Users::Invite).to have_received(:call).with(hash_including(wait_time: 0.minutes)).exactly(100).times
        expect(Users::Invite).to have_received(:call).with(hash_including(wait_time: 1.minute)).exactly(25).times
      end
    end

    context "when the array of user details is less than 100 elements" do
      before do
        allow(Users::Invite).to receive(:call).twice
      end

      it "creates the users and calls Users::Invite" do
        described_class.perform_now(user_details:)
        expect(Users::Invite).to have_received(:call).twice

        expect(User.find_by(first_name: "Joe", last_name: "Bloggs", email_address: "joe_bloggs@example.com")).to be_present
        expect(User.find_by(first_name: "Sue", last_name: "Doe", email_address: "sue_doe@example.com")).to be_present
      end

      context "when a user already exists" do
        before do
          create(:user, schools: [ school ], email_address: "joe_bloggs@example.com")
          allow(Users::Invite).to receive(:call)
        end

        it "does not create another user or call Users::Invite" do
          described_class.perform_now(user_details:)

          expect(Users::Invite).not_to have_received(:call)
          expect(User.where(email_address: "joe_bloggs@example.com").count).to eq(1)
        end
      end
    end
  end
end
