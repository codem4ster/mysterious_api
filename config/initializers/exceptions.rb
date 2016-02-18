module Exceptions
  ApiError = Class.new StandardError

  # User model exceptions
  UserCannotBeCreated = Class.new ApiError

end