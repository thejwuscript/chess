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

  def hypothetical_move(target, piece)
    set_piece_at(target, piece)
    delete_piece_at(piece.position)
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