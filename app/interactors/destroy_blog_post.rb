class DestroyBlogPost
  include Interactor

  def call
    context.blog_post or context.fail! errors: ['Blog post cannot be found']
    context.blog_post.destroy or context.fail! errors: ['Blog post cannot be deleted due to database error']
  end
end