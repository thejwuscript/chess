module Movement
  def validate_move(piece, target)
    return if same_color_at?(target, piece)
    
    pos_array = piece.position_to_array
    target_array = position_to_array(target)
    nil unless piece.move_manner.each do |manner|
      return target if depth_search(pos_array, manner, target_array)
      
    end
  end

  def within_limits?(array)
    array.all? { |num| num.between?(0, 7) } ? true : false
  end

  def occupied?(array)
    row, column = array
    grid[row][column] ? true : false
  end

  def same_color_at?(position, piece)
    if other_piece = piece_at(position)
      piece.color == other_piece.color ? true : false
    end
  end

  def depth_search(position_array, manner, target_array) # for Rook, Bishop, Queen
    next_array = position_array.zip(manner).map { |a, b| a + b }
    return unless within_limits?(next_array)
    return true if next_array == target_array
    return if occupied?(next_array)
    
    depth_search(next_array, manner, target_array)
  end
end