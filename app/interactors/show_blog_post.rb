class ShowBlogPost
  include Interactor

  def call
    context.blog_post or context.fail! errors: ['Blog post cannot be found']
    user = context.blog_post.user
    context.user = {id: user.id, nickname: user.nickname}
  end
end