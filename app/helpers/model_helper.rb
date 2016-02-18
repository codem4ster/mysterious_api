module ModelHelper

  # Stringify the errors for my api standart error visual type
  # {errors: ["some error", "some another error"]}
  # @return [Array<String>] stringified error messages of the model
  def stringify_errors
    errors.messages.map { |field, error| "#{field} #{error}" }
  end

end