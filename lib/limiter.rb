# frozen_string_literal: true

module Limiter
  
  def within_limits?(array)
    array.all? { |num| num.between?(0, 7) }
  end

end