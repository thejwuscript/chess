# frozen_string_literal: true

module Movement
  
  def validate_move(piece, target, game = nil)
    return if same_color_at?(target, piece)
    
    origin_array = piece.position_to_array
    target_array = position_to_array(target)
    return unless reach_target(origin_array, piece, target_array, game)
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

  def reach_target(origin_ary, piece, target_ary, game)
    if piece.is_a?(Rook) || piece.is_a?(Bishop) || piece.is_a?(Queen)
      depth_first_search(origin_ary, piece.move_manner, target_ary)
    elsif piece.is_a?(King) || piece.is_a?(Knight)
      breadth_search(origin_ary, piece.move_manner, target_ary)
    elsif piece.is_a?(Pawn)
      pawn_search(origin_ary, piece, target_ary, game)
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

  def pawn_search(origin_ary, piece, target_ary, game)
    if origin_ary.zip(target_ary).map { |a, b| ( a - b ).abs }.eql?([1, 1])
      pawn_attack(origin_ary, piece.color, target_ary, game)
    elsif piece.color == 'W'
      white_pawn_search(origin_ary, piece, target_ary)
    else
      black_pawn_search(origin_ary, piece, target_ary)
    end
  end

  def white_pawn_search(origin_ary, pawn, target_ary)
    a, b = origin_ary
    one_step = [a-1, b]
    return if occupied?(one_step) || occupied?(target_ary)
    
    target_ary if one_step == target_ary || pawn_double_step?(pawn, target_ary)
  end

  def black_pawn_search(origin_ary, pawn, target_ary)
    a, b = origin_ary
    one_step = [a+1, b]
    return if occupied?(one_step) || occupied?(target_ary)
    
    target_ary if one_step == target_ary || pawn_double_step?(pawn, target_ary)
  end

  def pawn_double_step?(pawn, target_ary)
    return if pawn.move_count > 0
    
    a, b = pawn.position_to_array
    true if pawn.color == 'W' && [a-2, b] == target_ary ||
            pawn.color == 'B' && [a+2, b] == target_ary
  end


  def pawn_attack(origin_ary, color, target_ary, game)
    a, b = target_ary
    if color == 'B' && a - origin_ary[0] == 1
      grid[a][b].nil? ? b_en_passant(a, b, game) : target_ary
    elsif color == 'W' && a - origin_ary[0] == -1
      grid[a][b].nil? ? w_en_passant(a, b, game) : target_ary
    end
  end

  def w_en_passant(row, column, game)
    piece = grid[row+1][column]
    [row, column] if piece.is_a?(Pawn) && piece.en_passantable?('B', game)
  end

  def b_en_passant(row, column, game)
    piece = grid[row-1][column]
    [row, column] if piece.is_a?(Pawn) && piece.en_passantable?('W', game)
  end

  def remove_pawn_captured_en_passant(piece, target, game)
    return unless piece.is_a?(Pawn) && target.match?(/3|6/)
    
    a, b = position_to_array(target)
    w_en_passant(a, b, game) ? grid[a+1][b] = nil : nil
    b_en_passant(a, b, game) ? grid[a-1][b] = nil : nil
  end

  def verify_king_move(king, target)
    if castling?(king, target)
      return valid_castling?(king, target) ? target : nil
      
    end  
    original_piece = piece_at(target)
    hypothetical_move(target, king)
    king_checked = checked?(king, target)
    set_piece_at(target, original_piece)
    set_piece_at(king.position, king)
    target unless king_checked
  end

  def move_castle(target)
    row = target[1]
    if target[0] == 'C'
      rook = piece_at("A#{row}")
      set_piece_at("D#{row}", rook)
      delete_piece_at(rook.position)
      rook.position = "D#{row}"
    elsif target[0] == 'G'
      rook = piece_at("H#{row}")
      set_piece_at("F#{row}", rook)
      delete_piece_at(rook.position)
      rook.position = "F#{row}"
    end
  end


  def castling?(king, target)
    return false if king.move_count > 0
    
    origin_ary = king.position_to_array
    target_ary = position_to_array(target)
    diff = origin_ary.zip(target_ary).map { |a, b| a - b }
    diff == [0, 2] || diff == [0, -2] ? true : false
  end

  def valid_castling?(king, target)
    origin_ary = king.position_to_array
    target_ary = position_to_array(target)
    true if right_castling?(origin_ary, king) || left_castling?(origin_ary, king, target_ary)
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
    a, b = origin_ary
    if b >= target_ary[1]
      return false if checked?(king, array_to_position([a, b]))
      
    end
    piece = grid[a][b - 1]
    if piece.is_a?(Rook)
      piece.move_count == 0 ? true : false
    else
      piece.nil? ? left_castling?([a, b - 1], king, target_ary) : false
    end
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

  def checkmate?(king, game)
    no_legal_moves?(king.color, game) && checked?(king, king.position) && no_counter?(king, king.color)
  end

  def stalemate?(king, game)
    no_legal_moves?(king.color, game) && !(checked?(king, king.position)) && no_counter?(king, king.color)
  end

  def no_legal_moves?(color, game)
    all_allies(color).none? { |piece| moves_available?(piece, game) }
  end

  def moves_available?(piece, game)
    array = []
    ('A'..'H').to_a.each do |letter|
      ('1'..'8').to_a.each { |number| array << letter + number }
    end
    array.any? { |move| validate_move(piece, move, game) }
  end

  def enemy_checking(king, target)
    color = king.color
    all_enemies(color).each { |enemy| return enemy if validate_move(enemy, target) == target }[0]
  end

  def all_allies(color)
    grid.flatten.compact.keep_if { |piece| piece.color == color }
  end

  def no_counter?(king, color)
    target = enemy_checking(king, king.position).position
    all_allies(color).none? { |ally| validate_move(ally, target) }
  end
end