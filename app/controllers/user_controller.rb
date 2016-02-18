class UserController < ApiController

  # List users with pagination
  # @option params [Integer] :page set current page of pagination
  # @option params [Integer] :item_size number of records per page
  # api_response:
  #   "page": 1,
  #   "item_size": 20,
  #   "total_count": 16,
  #   "users": [
  #     { "id": 1,  "nickname": "admin", "email": "carroll.kody.mr@green.name", "role": "admin" },
  #     {...}, ...
  #   ]
  def index
    authorize User
    args = Arguments.new params
    context = ListUsers.call args.take(:page, :item_size)
    render json: context_to_response(context)
  end

  def create
    args = Arguments.new params
    args.take :name, :nickname, :email, :password, :role
    authorize User.new args.taken
    context = CreateUser.call args.taken.merge({creator_user: current_user})
    render json: context_to_response(context)
  end

  def destroy
    user = User.where(id: params[:id]).first
    authorize(user || User)
    context = DestroyUser.call user: user
    render json: context_to_response(context)
  end

  def show
    user = User.where(id: params[:id]).first
    authorize(user || User)
    context = ShowUser.call user: user
    render json: context_to_response(context)
  end

end
