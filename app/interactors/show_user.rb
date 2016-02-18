class ShowUser
  include Interactor

  def call
    context.user or context.fail! errors: ['User cannot be found']
  end
end