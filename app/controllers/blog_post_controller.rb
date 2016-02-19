class BlogPostController < ApiController

  # List blog_posts with pagination
  # @option params [Integer] :page set current page of pagination
  # @option params [Integer] :item_size number of records per page
  # api_response:
  #   "page": 1,
  #   "item_size": 20,
  #   "total_count": 16,
  #   "blog_posts": [
  #     { "id": 1,  "title": "Sit molestiae ullam",
  #                 "description": "Voluptas itaque rerum autem eos aut est",
  #                 "content": "Veritatis reiciendis ipsam. Est accusantium",
  #                 "user": "gladys.wisozk" },
  #     {...}, ...
  #   ]
  def index
    authorize User
    args = Arguments.new params
    context = ListBlogPosts.call args.take(:page, :item_size)
    render json: context_to_response(context)
  end

  # Creates a blog post for logged in user
  # @option params [String] :title title of the post
  # @option params [String] :description explanation about post
  # @option params [String] :content body of the post
  # api_response:
  #   "title": "Sit molestiae ullam",
  #   "description": "Voluptas itaque rerum autem eos aut est",
  #   "content": "Veritatis reiciendis ipsam. Est accusantium",
  #   "blog_post_id": 25,
  #   "success": true
  def create
    args = Arguments.new params
    args.take *BlogPost.editable_column_names
    authorize BlogPost.new args.taken
    context = CreateBlogPost.call args.taken.merge({user: current_user})
    render json: context_to_response(context)
  end

  # Deletes a blog_post
  # @option params [Integer] :id id of the blog post
  # api_response:
  #   "blog_post": {
  #     "id": 25,
  #     "title": "Sit molestiae ullam",
  #     "description": "Voluptas itaque rerum autem eos aut est",
  #     "content": "Veritatis reiciendis ipsam. Est accusantium",
  #     "user_id": 1,
  #     "created_at": "2016-02-19T10:22:48.271Z",
  #     "updated_at": "2016-02-19T10:22:48.271Z"
  #   },
  #   "success": true
  def destroy
    blog_post = BlogPost.where(id: params[:id]).first
    authorize(blog_post || BlogPost)
    context = DestroyBlogPost.call blog_post: blog_post
    render json: context_to_response(context)
  end

  # Shows a blog_post
  # @option params [Integer] :id id of the blog_post
  # api_response:
  #   "blog_post": {
  #     "id": 1,
  #     "title": "Sit molestiae ullam voluptatibus molestias voluptatem saepe eos.",
  #     "description": "Voluptas itaque rerum autem eos aut est.",
  #     "content": "Veritatis reiciendis ipsam. Est accusantium fugit harum dolore doloremque.",
  #     "user_id": 2,
  #     "created_at": "2016-02-19T08:14:15.100Z",
  #     "updated_at": "2016-02-19T08:14:15.100Z"
  #   },
  #   "user": {
  #     "id": 2,
  #     "nickname": "gladys.wisozk"
  #   },
  #   "success": true
  def show
    blog_post = BlogPost.where(id: params[:id]).first
    authorize(blog_post || BlogPost)
    context = ShowBlogPost.call blog_post: blog_post
    render json: context_to_response(context)
  end

  # Updates a blog_post and returns changed parts
  # @option params [Integer] :id id of the blog_post
  # api_response:
  #   "title": "Changed Title",
  #   "blog_post_id": 1,
  #   "success": true
  def update
    blog_post = BlogPost.where(id: params[:id]).first
    authorize(blog_post || BlogPost)
    args = Arguments.new params
    args.take *BlogPost.editable_column_names
    context = UpdateBlogPost.call args.taken.merge({blog_post: blog_post})
    render json: context_to_response(context)
  end

end
