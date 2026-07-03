require 'rails_helper'

RSpec.describe "Pages", type: :request do
  shared_examples "a page with a single semantic footer" do |path|
    it "renders layout and footer correctly for #{path}" do
      get path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('class="govuk-template__body app-page"')
      expect(response.body).to include('class="govuk-main-wrapper app-page__main"')
      expect(response.body.scan(/<footer\b/).size).to eq(1)
      expect(response.body.scan(/<footer[^>]*class="[^"]*\bgovuk-footer\b[^"]*"/).size).to eq(1)
      expect(response.body).not_to include('<div class="govuk-footer"')
    end
  end

  include_examples "a page with a single semantic footer", "/"
  include_examples "a page with a single semantic footer", "/cookies"
  include_examples "a page with a single semantic footer", "/privacy"
  include_examples "a page with a single semantic footer", "/accessibility"
  include_examples "a page with a single semantic footer", "/terms_and_conditions"
end
