module SaveAndLoad
  def load_saved_file
    puts ''
    puts 'Would you like to load a previous game?'
    puts '    [1] -> Yes'
    puts '    [2] -> No'
    puts ''
    gets.chomp == '1' ? true : false
  end

  def save_game
    File.open("save_state.yaml", 'w') { |file| file.write save_to_yaml }
    puts "Game saved."
  end

  def save_to_yaml
    YAML.dump(
      'board' => @board,
      'turn_count' => @turn_count,
      'player_white' => @player_white,
      'player_black' => @player_black,
      'current_player' => @current_player,
      'winner' => @winner
    )
  end

  def load_from_yaml
    saved_info = YAML.load_file('save_state.yaml')
    assign_saved_values(saved_info)
    puts 'Game loaded.'
    board.show_board
    move_piece
    promote_pawn
  end

  def assign_saved_values(hash)
    self.board = hash['board']
    self.turn_count = hash['turn_count']
    self.player_white = hash['player_white']
    self.player_black = hash['player_black']
    self.current_player = hash['current_player']
    self.winner = hash['winner']
  end
end