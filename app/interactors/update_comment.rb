class UpdateComment
  include Interactor

  def update_comment
    context.comment or context.fail! errors: ['Comment cannot be found']
    context.comment.attributes = context.to_h.select { |column| Comment.editable_column_names.include? column }
    context.comment.valid? or context.fail! errors: @comment.stringify_errors
    context.comment.save or context.fail! errors: ['Comment cannot be updated due to database error']
    context.comment_id = context.comment.id
  end

  def clear_context
    fields = [ :comment ]
    fields.each { |field| context.delete_field field }
  end

  def call
    update_comment
    # if not failed interactor can respond
    clear_context
  end
end