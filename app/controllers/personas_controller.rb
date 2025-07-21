class PersonasController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @personas = User.where(email_address: PERSONA_EMAILS).order(:created_at)
  end
end
