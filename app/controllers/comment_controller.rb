class CommentController < ApiController
  def index
    authorize Comment
    args = Arguments.new params
    context = ListComments.call args.take(:page, :item_size)
    render json: context_to_response(context)
  end

  def create
    args = Arguments.new params
    args.take *Comment.editable_column_names.push(:blog_post_id)
    authorize Comment.new args.taken
    blog_post = BlogPost.where(id: params[:blog_post_id]).first
    context = CreateComment.call args.taken.merge({user: current_user, blog_post: blog_post})
    render json: context_to_response(context)
  end

  def destroy
    comment = Comment.where(id: params[:id]).first
    authorize(comment || Comment)
    context = DestroyComment.call comment: comment
    render json: context_to_response(context)
  end

  def show
    comment = Comment.where(id: params[:id]).first
    authorize(comment || Comment)
    context = ShowComment.call comment: comment
    render json: context_to_response(context)
  end

  def update
    comment = Comment.where(id: params[:id]).first
    authorize(comment || Comment)
    args = Arguments.new params
    args.take *Comment.editable_column_names
    context = UpdateComment.call args.taken.merge({comment: comment})
    render json: context_to_response(context)
  end
end
