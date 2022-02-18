# frozen_string_literal: true

module SaveAndLoad
  def choose_load_game
    puts ''
    puts 'Would you like to load a previous game?'
    puts '    [1] -> Yes'
    puts '    [2] -> No'
    puts ''
    choice = gets.chomp == '1' ? true : false
  end

  def load_or_new_game
    return Game.new.new_game unless saved_game_exists?

    choose_load_game ? load_game : Game.new.new_game
  rescue SystemCallError
    no_saved_game_message
    Game.new.new_game
  end

  def saved_game_exists?
    File.exist?('save_state.yaml')
  end

  def load_game
    load_from_yaml.resume_game
  end

  def save_game
    File.open("save_state.yaml", 'w') { |file| file.write save_to_yaml }
    puts "Game saved."
    choose_piece_message(self.name)
  end

  def save_to_yaml
    YAML.dump(self.game)
  end

  def load_from_yaml
    YAML.load_file('save_state.yaml')
  end

  def no_saved_game_message
    puts ''
    puts 'No saved game found. A new game will begin.'
    puts ''
  end

  def save_board_info 
    previous = board.grid.flatten.compact.find { |piece| piece.selected }
    File.open("prev_board_info.yaml", 'w') do |file| 
      file.write YAML.dump({
        'grid' => board.grid,
        'origin_ary' => board.origin_ary,
        'attacking_arrays' => board.attacking_arrays
        })
    end
  end

  def load_board_info 
    YAML.load_file('prev_board_info.yaml')
  end
end