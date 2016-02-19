class CreateUser
  include Interactor

  def create_user
    @user = User.new context.to_h
    @user.confirmation_sent_at = Time.now
    @user.confirmed_at = Time.now
    @user.valid? or context.fail! errors: @user.stringify_errors
    @user.save or context.fail! errors: ['User cannot be saved due to database error']
  end

  def clear_context
    fields = [ :creator_user, :password, :role ]
    fields.each { |field| context.delete_field field if context[field] }
  end

  def call
    create_user
    # if not failed interactor can respond
    clear_context
    context.success = true
    context.user_id = @user.id
  end
end