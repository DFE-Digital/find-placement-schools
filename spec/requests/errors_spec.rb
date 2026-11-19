require "rails_helper"

RSpec.describe "Errors", type: :request do
  describe "GET /404" do
    it "renders the not found page" do
      get "/404"

      expect(response).to have_http_status(:not_found)
      expect(response).to render_template("errors/not_found")
    end
  end

  describe "GET /422" do
    it "renders the unprocessable entity page" do
      get "/422"

      expect(response).to have_http_status(422)
      expect(response).to render_template("errors/unprocessable_entity")
    end
  end

  describe "GET /429" do
    it "renders the too many requests page" do
      get "/429"

      expect(response).to have_http_status(:too_many_requests)
      expect(response).to render_template("errors/too_many_requests")
    end
  end
end
