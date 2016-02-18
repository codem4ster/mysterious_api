class BlogPostController < ApiController

  def index
    authorize User
    args = Arguments.new params
    context = ListBlogPosts.call args.take(:page, :item_size)
    render json: context_to_response(context)
  end

  def create
    args = Arguments.new params
    args.take *BlogPost.editable_column_names
    authorize BlogPost.new args.taken
    context = CreateBlogPost.call args.taken.merge({user: current_user})
    render json: context_to_response(context)
  end

  def destroy
    blog_post = BlogPost.where(id: params[:id]).first
    authorize(blog_post || BlogPost)
    context = DestroyBlogPost.call blog_post: blog_post
    render json: context_to_response(context)
  end

  def show
    blog_post = BlogPost.where(id: params[:id]).first
    authorize(blog_post || BlogPost)
    context = ShowBlogPost.call blog_post: blog_post
    render json: context_to_response(context)
  end

  def update
    blog_post = BlogPost.where(id: params[:id]).first
    authorize(blog_post || BlogPost)
    args = Arguments.new params
    args.take *BlogPost.editable_column_names
    context = UpdateBlogPost.call args.taken.merge({blog_post: blog_post})
    render json: context_to_response(context)
  end

end
