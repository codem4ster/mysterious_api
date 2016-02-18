class DestroyUser
  include Interactor

  def call
    context.user or context.fail! errors: ['User cannot be found']
    context.user.destroy or context.fail! errors: ['User cannot be deleted due to database error']
  end
end