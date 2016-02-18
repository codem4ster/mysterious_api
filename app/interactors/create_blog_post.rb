class CreateBlogPost
  include Interactor

  def create_blog_post
    @blog_post = BlogPost.new context.to_h
    @blog_post.valid? or context.fail! errors: @blog_post.stringify_errors
    @blog_post.save or context.fail! errors: ['Blog post cannot be saved due to database error']
  end

  def clear_context
    fields = [ :user ]
    fields.each { |field| context.delete_field field }
  end

  def call
    create_blog_post
    # if not failed interactor can respond
    clear_context
    context.blog_post_id = @blog_post.id
  end
end