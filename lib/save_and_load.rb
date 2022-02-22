# frozen_string_literal: true

module SaveAndLoad
  def load_game?
    puts ''
    puts 'Would you like to load a previous game?'
    puts '    [1] -> Yes'
    puts '    [2] -> No'
    puts ''
    gets.chomp == '1' ? true : false
  end

  def saved_game_exists?
    File.exist?('save_state.yaml')
  end

  def save_game
    File.open("save_state.yaml", 'w') { |file| file.write save_to_yaml }
    puts "Game saved."
  end

  def save_to_yaml
    YAML.dump(self)
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
    File.open("temp_board_info.yaml", 'w') do |file| 
      file.write YAML.dump({
        'grid' => board.grid,
        'origin_ary' => board.origin_ary,
        'attacking_arrays' => board.attacking_arrays
        })
    end
  end

  def load_board_info 
    YAML.load_file('temp_board_info.yaml')
  end
end