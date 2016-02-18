class ListComments
  include Interactor

  def set_defaults
    context.page = context.page ? context.page.to_i : 1
    context.item_size = context.item_size ? context.item_size.to_i : 20
  end

  def context_valid?
    context.page > 0 or context.fail! errors: ['Page must be greater than 0']
    context.item_size > 0 or context.fail! errors: ['Item size must be greater than 0']
  end

  def call
    set_defaults
    context_valid?
    context.total_count = Comment.count
    comments = Comment.in_page(context.page, with_size: context.item_size).all
    context.comments = comments.map do |comment|
      { id: comment.id, title: comment.title, message: comment.message,
        user: comment.user.nickname, blog_post: comment.blog_post.title }
    end
  end
end