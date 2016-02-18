class BlogPostPolicy < ApplicationPolicy

  def index?
    @user and ['admin', 'user', 'guest'].include? @user.role
  end

  def create?
    @user and ['admin', 'user'].include? @user.role
  end

  def show?
    index?
  end

  def update?
    create? and (@user.role == 'user' ? @record.user == @user : true)
  end

  def destroy?
    update?
  end

end