module Movement
  
  def validate_move(piece, target)
    return if same_color_at?(target, piece)
    
    origin_array = piece.position_to_array
    target_array = position_to_array(target)
    reach_target?(origin_array, piece, target_array) ? target : nil
  end

  def reach_target?(origin_ary, piece, target_ary)
    if piece.is_a?(Rook) || piece.is_a?(Bishop) || piece.is_a?(Queen)
      depth_first_search(origin_ary, piece.move_manner, target_ary)
    elsif piece.is_a?(King) || piece.is_a?(Knight)
      return true if breadth_search
    elsif piece.is_a?(Pawn)
      return true if pawn_search
    end
  end

  def depth_first_search(origin_ary, manners, target_ary)
    for i in 0..manners.size-1 do
      return target_ary if recursive_search(origin_ary, manners[i], target_ary)
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

  def recursive_search(origin_array, manner, target_array)
    next_array = origin_array.zip(manner).map { |a, b| a + b }
    return nil unless within_limits?(next_array)
    return target_array if next_array == target_array
    return nil if occupied?(next_array)
    
    recursive_search(next_array, manner, target_array)
  end
end