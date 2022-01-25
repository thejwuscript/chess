module GameMessage

  def choose_piece_message
    puts "#{current_player.name}, enter a coordinate to choose a piece to move. (Example: g5)"
  end

  def choose_move_message
    puts 'Enter a coordinate to move your piece to.'
  end

  def invalid_input_message
    puts 'Invalid entry. Please try again.'
  end

  def get_name_message
    puts ''
    print "Player #{yield}, please enter your name: "
  end

  def show_player_assignment
    puts ''
    puts "#{player_white.name} is white."
    puts "#{player_black.name} is black."
    puts ''
    puts "#{player_white.name} will go first."
    sleep 3
  end

  def declare_winner
    puts "The winner is #{winner.name}! Congratulations!"
  end

  def declare_draw
    puts "It's a draw!"
  end
end