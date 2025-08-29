class SupportUserConstraint
  def matches?(request)
    current_user = DfeSignInUser.load_from_session(request.session)&.user
    current_user&.admin?
  end
end
