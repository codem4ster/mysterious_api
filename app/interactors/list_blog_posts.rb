class ListBlogPosts
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
    context.total_count = BlogPost.count
    blog_posts = BlogPost.in_page(context.page, with_size: context.item_size).all
    context.blog_posts = blog_posts.map do |blog_post|
      { id: blog_post.id, title: blog_post.title, description: blog_post.description, content: blog_post.content,
        user: blog_post.user.nickname }
    end
  end
end