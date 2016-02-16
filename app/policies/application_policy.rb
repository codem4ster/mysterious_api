# Policy rules' base class for pundit
# @author Onur Eren Elibol
# @attr_reader [User] current_user
# @attr_reader [BlogPost, Comment, User] model
class ApplicationPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @model = model
  end
end