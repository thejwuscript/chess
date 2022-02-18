module GameMessage

  def game_loaded_message
    puts ''
    puts 'Game loaded.'
    puts ''
    sleep 1
  end

  def choose_piece_message(player)
    puts ''
    puts "#{player.name}(#{player.color}), enter a coordinate to choose a piece. (Example: g5)"
    puts "You may enter 'S' to save the game."
    puts ''
  end

  def choose_move_message(piece)
    puts ''
    puts "Enter a coordinate to move your #{piece.type} to,"
    puts "or enter 'U' to choose another piece."
    puts ''
  end

  def choose_game_message
    puts ''
    puts "Enter '1' to vs Computer."
    puts "Enter '2' to vs another player."
    puts ''
  end

  def invalid_input_message
    puts 'Invalid entry. Please try again.'
  end

  def get_name_message
    puts ''
    print "#{yield}, please enter your name: "
  end

  def show_player_assignment
    puts ''
    puts "#{player_white.name} is white."
    puts "#{player_black.name} is black."
    puts ''
    puts "#{player_white.name} will go first."
    sleep 3
    puts ''
  end

  def king_checked_message(king)
    puts "#{current_player.name}, your king at #{king.position} is in check!"
  end

  def declare_winner
    puts ''
    puts 'CHECKMATE!'
    puts "The winner is #{winner.name}! Congratulations!"
  end

  def declare_draw
    puts "STALEMATE! It's a draw!"
  end

  def promotion_message
    puts "#{name}, your pawn can be promoted!"
    puts 'Choose the following options by entering a number from 1 to 4:'
    puts '    [1] --> Queen'
    puts '    [2] --> Rook'
    puts '    [3] --> Bishop'
    puts '    [4] --> Knight'
    puts ''
  end

  def ai_promote_message(piece)
    puts ''
    puts "The computer promoted a pawn to a #{piece.type} at #{piece.position}!"
    sleep 5
    puts ''
  end

  def en_passant_message(game)
    puts ''
    puts "#{self.name}: HA! I'm taking your pawn \e[3men-passant\e[0m!"
    sleep 4
    opponent = self.color == 'W' ? game.player_black : game.player_white
    puts ''
    puts "#{opponent.name}: ..."
    sleep 3
    puts "#{opponent.name}: Hold my croissant."
    sleep 3
    puts ''
  end

  def computer_move_message(examiner)
    piece = examiner.piece.type
    target_position = examiner.target
    puts ''
    puts "Computer moves #{piece} to #{target_position}."
  end
end
