module Movement
  
  def validate_move(piece, target)
    return if same_color_at?(target, piece)
    
    origin_array = piece.position_to_array
    target_array = position_to_array(target)
    target_reachable?(origin_array, piece, target_array) ? target : nil
  end

  def target_reachable?(origin, piece, target)
    if piece.is_a?(Rook) || piece.is_a?(Bishop) || piece.is_a?(Queen)
      manners = piece.move_manner
      manners.each { |i| return true if depth_search(origin, i, target) }
    elsif piece.is_a?(King) || piece.is_a?(Knight)
      return true if breadth_search
    elsif piece.is_a?(Pawn)
      return true if pawn_search
    end
    nil
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

  def depth_search(origin_array, manner, target_array)
    next_array = origin_array.zip(manner).map { |a, b| a + b }
    return unless within_limits?(next_array)
    return true if next_array == target_array
    return if occupied?(next_array)
    
    depth_search(next_array, manner, target_array)
  end
end