class DestroyComment
  include Interactor

  def call
    context.comment or context.fail! errors: ['Comment cannot be found']
    context.comment.destroy or context.fail! errors: ['Comment cannot be deleted due to database error']
  end
end