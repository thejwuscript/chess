# frozen_string_literal: true

module SaveAndLoad
  def load_or_new_game
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

  def load_game
    puts 'Game loaded.'
    load_from_yaml.game.resume_game 
  end

  def assign_saved_values(hash)
    self.board = hash['board']
    self.turn_count = hash['turn_count']
    self.player_white = hash['player_white']
    self.player_black = hash['player_black']
    self.current_player = hash['current_player']
    self.winner = hash['winner']
  end

  def no_saved_game_message
    puts ''
    puts 'No saved game found. A new game will begin.'
    puts ''
  end
end