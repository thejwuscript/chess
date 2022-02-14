module GameMessage

  def choose_piece_message(name)
    puts ''
    puts "#{name}, enter a coordinate to choose a piece. (Example: g5)"
    puts "You may enter 'S' to save the game."
  end

  def choose_move_message(piece)
    puts "Enter a coordinate to move your #{piece.type} to."
  end

  def choose_game_message
    puts "Press '1' to vs Computer."
    puts "Press '2' to vs another player."
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
    puts "#{current_player.name}, your pawn can be promoted!"
    puts 'Choose the following options by entering a number from 1 to 4:'
    puts '    [1] --> Queen'
    puts '    [2] --> Rook'
    puts '    [3] --> Bishop'
    puts '    [4] --> Knight'
    puts ''
  end
end
