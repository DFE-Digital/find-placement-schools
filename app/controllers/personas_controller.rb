class PersonasController < ApplicationController
  def index
    @personas = User.where(email_address: PERSONA_EMAILS).order(:created_at)
  end
end
