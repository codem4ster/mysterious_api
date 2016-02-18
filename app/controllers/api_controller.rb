class ApiController < ApplicationController

  include Pundit
  after_action :verify_authorized
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    render json: {success: false, errors: ["You are not authorized to do this !!!"]}, status: 403
  end

  def context_to_response(context)
    if context.success?
      context.success = true
      context.to_h
    else
      {success: false, errors: context.errors}
    end
  end

end