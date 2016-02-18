class UserPolicy < ApplicationPolicy

  def index?
    @user and ['admin', 'user', 'guest'].include? @user.role
  end

  def create?
    # user can only create other users not admin
    @user and ['admin', 'user'].include? @user.role and
      (@user.role == 'user' ? @record.role == 'user' : true)
  end

  def show?
    index?
  end

  def destroy?
    @user and
      @user != @record and
      ['admin', 'user'].include? @user.role and
      (@user.role == 'user' ? @record.creator_user == @user : true)
  end

end
