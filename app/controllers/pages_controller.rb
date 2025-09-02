class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  PAGES_DIR = Rails.root.join("app", "views", "pages").freeze

  def home; end

  def show
    page = params[:page].to_s
    base = PAGES_DIR.to_s
    path = File.expand_path("#{page}.md", base)
    render locals: {
      page:,
      content: File.read(path)
    }
  end
end
