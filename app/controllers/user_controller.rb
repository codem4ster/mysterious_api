class UserController < ApiController

  # List users with pagination
  # @option params [Integer] :page set current page of pagination
  # @option params [Integer] :item_size number of records per page
  # api_response:
  #   "page": 1,
  #   "item_size": 20,
  #   "total_count": 160,
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

  # Creates a user
  # @option params [String] :name real name of the user like "Onur Eren Elibol"
  # @option params [String] :nickname username of the user
  # @option params [String] :email email of the user, must be valid
  # @option params [String] :password devise will encrypt this, must greater than 8 chars
  # @option params [String] :role must be one of these "admin", "user", "guest"
  # api_response:
  #   "name": "Carroll Kody",
  #   "email": "carroll.kody.mr@green.name",
  #   "success": true,
  #   "user_id": 20
  def create
    args = Arguments.new params
    args.take :name, :nickname, :email, :password, :role
    authorize User.new args.taken
    context = CreateUser.call args.taken.merge({creator_user: current_user})
    render json: context_to_response(context)
  rescue ArgumentError
    authorize User
    render json: {success: false, errors:["Role must be admin, user or guest"]}
  end

  # Deletes a user
  # @option params [Integer] :id id of the user
  # api_response:
  #   "user": {
  #     "id": 20,
  #     "provider": "email",
  #     "uid": "carroll.kody.mr@green.name",
  #     "name": "Carroll Kody",
  #     "nickname": null,
  #     "image": null,
  #     "email": "carroll.kody.mr@green.name",
  #     "role": "admin",
  #     "created_at": "2016-02-19T10:10:58.055Z",
  #     "updated_at": "2016-02-19T10:10:58.055Z",
  #     "creator_user_id": 1
  #   },
  #   "success": true
  def destroy
    user = User.where(id: params[:id]).first
    authorize(user || User)
    context = DestroyUser.call user: user
    render json: context_to_response(context)
  end

  # Shows a user
  # @option params [Integer] :id id of the user
  # api_response:
  #   "user": {
  #     "id": 20,
  #     "provider": "email",
  #     "uid": "carroll.kody.mr@green.name",
  #     "name": "Carroll Kody",
  #     "nickname": null,
  #     "image": null,
  #     "email": "carroll.kody.mr@green.name",
  #     "role": "admin",
  #     "created_at": "2016-02-19T10:10:58.055Z",
  #     "updated_at": "2016-02-19T10:10:58.055Z",
  #     "creator_user_id": 1
  #   },
  #   "success": true
  def show
    user = User.where(id: params[:id]).first
    authorize(user || User)
    context = ShowUser.call user: user
    render json: context_to_response(context)
  end

end
