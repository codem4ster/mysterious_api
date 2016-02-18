class ShowComment
  include Interactor

  def call
    context.comment or context.fail! errors: ['Comment cannot be found']

    # take comment and clear from namespace
    comment = context.comment
    context.user = {id: comment.user.id, nickname: comment.user.nickname}
    context.blog_post = { id: comment.blog_post.id, title: comment.blog_post.title }
  end

end