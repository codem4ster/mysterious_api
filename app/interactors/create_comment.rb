class CreateComment
  include Interactor

  def create_comment
    context.blog_post or context.fail! errors: ['Cannot find blog post to be commented']
    @comment = Comment.new context.to_h
    @comment.valid? or context.fail! errors: @comment.stringify_errors
    @comment.save or context.fail! errors: ['Comment cannot be saved due to database error']
  end

  def clear_context
    fields = [ :user, :blog_post ]
    fields.each { |field| context.delete_field field }
  end

  def call
    create_comment
    # if not failed interactor can respond
    clear_context
    context.success = true
    context.comment_id = @comment.id
  end
end