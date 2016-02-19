class CommentController < ApiController

  # List blog_posts with pagination
  # @option params [Integer] :page set current page of pagination
  # @option params [Integer] :item_size number of records per page
  # api_response:
  #   "page": 1,
  #   "item_size": 20,
  #   "total_count": 50,
  #   "comments": [
  #     { "id": 1,  "title": "Sit molestiae ullam",
  #                 "message": "Voluptas itaque rerum autem eos aut est",
  #                 "blog_post": "Title of the related blog post",
  #                 "user": "gladys.wisozk" },
  #     {...}, ...
  #   ]
  def index
    authorize Comment
    args = Arguments.new params
    context = ListComments.call args.take(:page, :item_size)
    render json: context_to_response(context)
  end

  # Creates a comment for logged in user to blog post
  # @option params [String] :title title of the comment
  # @option params [String] :message explanation about comment
  # @option params [Integer] :blog_post_id id of the blog post which will be commented
  # api_response:
  #   "title": "Sit molestiae ullam",
  #   "message": "Voluptas itaque rerum autem eos aut est",
  #   "comment_id": 25,
  #   "success": true
  def create
    args = Arguments.new params
    args.take *Comment.editable_column_names.push(:blog_post_id)
    authorize Comment.new args.taken
    blog_post = BlogPost.where(id: params[:blog_post_id]).first
    context = CreateComment.call args.taken.merge({user: current_user, blog_post: blog_post})
    render json: context_to_response(context)
  end

  # Deletes a comment
  # @option params [Integer] :id id of the comment
  # api_response:
  #   "comment": {
  #     "id": 25,
  #     "title": "Sit molestiae ullam",
  #     "message": "Voluptas itaque rerum autem eos aut est",
  #     "user_id": 1,
  #     "created_at": "2016-02-19T10:22:48.271Z",
  #     "updated_at": "2016-02-19T10:22:48.271Z"
  #   },
  #   "success": true
  def destroy
    comment = Comment.where(id: params[:id]).first
    authorize(comment || Comment)
    context = DestroyComment.call comment: comment
    render json: context_to_response(context)
  end

  # Shows a comment
  # @option params [Integer] :id id of the comment
  # api_response:
  #   "comment": {
  #     "id": 1,
  #     "title": "Sit molestiae ullam voluptatibus molestias voluptatem saepe eos.",
  #     "message": "Voluptas itaque rerum autem eos aut est.",
  #     "user_id": 2,
  #     "blog_post_id": 5
  #     "created_at": "2016-02-19T08:14:15.100Z",
  #     "updated_at": "2016-02-19T08:14:15.100Z"
  #   },
  #   "user": {
  #     "id": 2,
  #     "nickname": "gladys.wisozk"
  #   },
  #   "blog_post": {
  #     "id": 5,
  #     "title": "Voluptas quia laboriosam laborum earum."
  #   },
  #   "success": true
  def show
    comment = Comment.where(id: params[:id]).first
    authorize(comment || Comment)
    context = ShowComment.call comment: comment
    render json: context_to_response(context)
  end

  # Updates a comment and returns changed parts
  # @option params [Integer] :id id of the comment
  # api_response:
  #   "title": "Changed Title",
  #   "comment_id": 1,
  #   "success": true
  def update
    comment = Comment.where(id: params[:id]).first
    authorize(comment || Comment)
    args = Arguments.new params
    args.take *Comment.editable_column_names
    context = UpdateComment.call args.taken.merge({comment: comment})
    render json: context_to_response(context)
  end
end
