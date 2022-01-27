module Movement
  
  def validate_move(piece, target)
    return if same_color_at?(target, piece)
    
    origin_array = piece.position_to_array # Depend on inst var
    target_array = position_to_array(target)
    return unless reach_target(origin_array, piece, target_array)
    return verify_king_move(piece, target) if piece.is_a? King
    
    own_king_exposed?(piece, target) ? nil : target
  end

  def own_king_exposed?(piece, target)
    removed_piece = piece_at(target)
    hypothetical_move(target, piece)
    king_checked = find_checked_king
    set_piece_at(target, removed_piece)
    set_piece_at(piece.position, piece)
    king_checked && king_checked.color == piece.color ? true : false
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
    array.all? { |num| num.between?(0, 7) }
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
      next unless within_limits?(next_array)
      return target_array if next_array == target_array
    end
  end

  def pawn_search(origin_ary, piece, target_ary)
    if origin_ary.zip(target_ary).map { |a, b| ( a - b ).abs }.eql?([1, 1])
      pawn_attack(origin_ary, piece.color, target_ary)
    elsif piece.color == 'W'
      white_pawn_search(origin_ary, piece, target_ary)
    else
      black_pawn_search(origin_ary, piece, target_ary)
    end
  end

  def white_pawn_search(origin_ary, pawn, target_ary)
    a, b = origin_ary
    return if occupied?(target_ary) || occupied?([a-1, b])
    
    if pawn.start_position == pawn.position && [a-2, b] == target_ary
      pawn.store_turn_count
      target_ary
    else
      target_ary if [a-1, b] == target_ary
    end
  end

  def black_pawn_search(origin_ary, pawn, target_ary)
    a, b = origin_ary
    return if occupied?(target_ary) || occupied?([a+1, b])
    
    if pawn.start_position == pawn.position && [a+2, b] == target_ary
      pawn.store_turn_count
      target_ary
    else
      target_ary if [a+1, b] == target_ary
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
    if piece.is_a?(Pawn) && piece.en_passantable?('B')
      delete_piece_at(piece.position)
      [row, column]
    end
  end

  def b_en_passant(row, column)
    piece = grid[row-1][column]
    if piece.is_a?(Pawn) && piece.en_passantable?('W')
      delete_piece_at(piece.position)
      [row, column] 
    end
  end

  def verify_king_move(king, target)
    return if castling?(king, target)
    
    original_piece = piece_at(target)
    hypothetical_move(target, king)
    king_checked = checked?(king, target)
    set_piece_at(target, original_piece)
    set_piece_at(king.position, king)
    target unless king_checked
  end

  def castling?(king, target)
    return false if king.move_count > 0
    
    origin_ary = king.position_to_array
    target_ary = position_to_array(target)
    diff = origin_ary.zip(target_ary).map { |a, b| a - b }
    
    return false unless diff == [0, 2] || diff == [0, -2]

    return right_castling?(origin_ary, king) if diff == [0, -2]
    
    left_castling?(origin_ary, king, target_ary) if diff == [0, 2]
  end

  def right_castling?(origin_ary, king)
    a, b = origin_ary
    return false if checked?(king, array_to_position([a, b]))
    
    piece = grid[a][b + 1]
    if piece.is_a?(Rook)
      piece.move_count == 0 ? true : false
    else
      piece.nil? ? right_castling?([a, b + 1], king) : false
    end
  end

  def left_castling?(origin_ary, king, target_ary)
    # mind that no need to check for check condition for last square.
  end

  def hypothetical_move(target, piece)
    set_piece_at(target, piece)
    delete_piece_at(piece.position)
  end

  def checked?(king, target)
    color = king.color
    all_enemies(color).any? { |enemy| validate_move(enemy, target) == target }
  end

  def all_enemies(color)
    grid.flatten.reject { |piece| piece.nil? || piece.color == color }
  end

  def checkmate?(king)
    no_legal_moves?(king) && checked?(king, king.position)
  end

  def stalemate?(king)
    no_legal_moves?(king) && !(checked?(king, king.position))
  end

  def no_legal_moves?(king)
    king.possible_moves.none? { |move| validate_move(king, move) }
  end

end