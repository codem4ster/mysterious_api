class UpdateBlogPost
  include Interactor

  def update_blog_post
    context.blog_post or context.fail! errors: ['Blog post cannot be found']
    context.blog_post.attributes = context.to_h.select { |column| BlogPost.editable_column_names.include? column }
    context.blog_post.valid? or context.fail! errors: @blog_post.stringify_errors
    context.blog_post.save or context.fail! errors: ['Blog post cannot be updated due to database error']
    context.blog_post_id = context.blog_post.id
  end

  def clear_context
    fields = [ :blog_post ]
    fields.each { |field| context.delete_field field }
  end

  def call
    update_blog_post
    # if not failed interactor can respond
    clear_context
  end
end