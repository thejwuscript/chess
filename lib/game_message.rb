module GameMessage

  def enter_input_message
    puts "#{current_player.name}, enter a coordinate to choose a piece to move. (Example: g5)"
  end

  def invalid_input_message
    puts 'Invalid entry. Please try again.'
  end

  def get_name_message
    puts ''
    print "Player #{yield}, please enter your name: "
  end

  def show_player_assignment
    puts "#{player_white.name} is white."
    puts "#{player_black.name} is black."
    puts ''
    puts "#{player_white.name} will go first."
    sleep 3
  end
end