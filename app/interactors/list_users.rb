class ListUsers
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
    context.total_count = User.count
    users = User.in_page(context.page, with_size: context.item_size).all
    context.users = users.map do |user|
      {id: user.id, nickname: user.nickname, email: user.email, role: user.role}
    end
  end
end
