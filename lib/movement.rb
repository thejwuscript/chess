module Movement
  
  def validate_move(piece, target)
    return if same_color_at?(target, piece)
    
    origin_array = piece.position_to_array
    target_array = position_to_array(target)
    reach_target(origin_array, piece, target_array) ? target : nil
  end

  def reach_target(origin_ary, piece, target_ary)
    if piece.is_a?(Rook) || piece.is_a?(Bishop) || piece.is_a?(Queen)
      depth_first_search(origin_ary, piece.move_manner, target_ary)
    elsif piece.is_a?(King) || piece.is_a?(Knight)
      breadth_search(origin_ary, piece.move_manner, target_ary)
    elsif piece.is_a?(Pawn)
      pawn_search(origin_ary, piece, target_ary)
    end
  end

  def depth_first_search(origin_ary, manners, target_ary)
    nil unless for i in 0..manners.size-1 do
      return target_ary if recursive_search(origin_ary, manners[i], target_ary)
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

  def recursive_search(origin_array, manner, target_array)
    next_array = origin_array.zip(manner).map { |a, b| a + b }
    return nil unless within_limits?(next_array)
    return target_array if next_array == target_array
    return nil if occupied?(next_array)
    
    recursive_search(next_array, manner, target_array)
  end
  
  def breadth_search(origin_array, manners, target_array)
    until manners.empty? do
      next_array = origin_array.zip(manners.shift).map { |a, b| a + b }
      return target_array if next_array == target_array
    end
  end

  def pawn_search(origin_ary, piece, target_ary)
    if origin_ary.zip(target_ary).map { |a, b| ( a - b ).abs }.eql?([1, 1])
      # pawn_attack(origin_ary, piece.color, target_ary)
    elsif piece.color == 'W'
      white_pawn_search(origin_ary, piece, target_ary)
    else
      black_pawn_search(origin_ary, piece, target_ary)
    end
  end

  def white_pawn_search(origin_ary, pawn, target_ary)
    a, b = origin_ary
    if pawn.start_position == pawn.position && [a-2, b] == target_ary
      pawn.store_turn_count
      target_ary
    else
      target_ary if [a-1, b] == target_ary
    end
  end

  def black_pawn_search(origin_array, pawn, target_array)
    a, b = origin_array
    if pawn.start_position == pawn.position && [a+2, b] == target_array
      pawn.store_turn_count
      target_array
    else
      target_array if [a+1, b] == target_array
    end
  end

  def pawn_attack(origin_ary, color, target_ary)
    a, b = target_ary
    if color == 'B' && a - origin_ary[0] == 1
      grid[a][b].nil? ? b_en_passant(a, b) : target_ary
    elsif color == 'W' && a - origin_ary[0] == -1
      grid[a][b].nil? ? w_en_passant(a, b) : target_ary
    end
  end

  def w_en_passant(row, column)
    piece = grid[row+1][column]
    [row, column] if piece.is_a?(Pawn) && piece.en_passantable?('B')
  end

  def b_en_passant(row, column)
    piece = grid[row-1][column]
    [row, column] if piece.is_a?(Pawn) && piece.en_passantable?('W')
  end
end