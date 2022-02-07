#frozen_string_literal: true

class MoveExaminer
  def within_limits?(array)
    array.all? { |num| num.between?(0, 7) }
  end
end
