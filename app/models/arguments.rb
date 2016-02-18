class Arguments

  attr_reader :taken

  def initialize(params)
    @params = params
  end

  # filter the param values to secure the interaction contexts
  #   only ours selected parameters can pass here
  def take(*args)
    @taken = @params.select do |key, _|
      args.include? key.to_sym
    end.permit!
  end

end