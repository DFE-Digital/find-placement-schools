require "rails_helper"

RSpec.describe HostingEnvironment do
  before do
    described_class.instance_variable_set :@env, nil
    described_class.instance_variable_set :@phase, nil
  end

  describe ".env" do
    subject(:env) { described_class.env }

    test_matrix = %w[production sandbox staging qa review development test]

    test_matrix.each do |environment|
      context "when HOSTING_ENV is '#{environment}'" do
        it "returns '#{environment}'" do
          ClimateControl.modify HOSTING_ENV: environment do
            expect(env).to eq(environment)
          end
        end
      end
    end
  end
end
