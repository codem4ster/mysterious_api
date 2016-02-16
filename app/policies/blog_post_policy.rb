class BlogPostPolicy < ApplicationPolicy

  def index?
    @current_user.admin? or @current_user.user? or @current_user.guest?
  end

  def show?
    @current_user.admin? or @current_user.user? or @current_user.guest?
  end

  def update?
    @current_user.admin? or @current_user == @model
  end

  def destroy?
    not @current_user == @model and @current_user.admin?
  end

end