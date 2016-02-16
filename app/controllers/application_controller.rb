class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken

  include Pundit
  after_action :verify_authorized

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  # It welcomes the /
  def index

  end

end