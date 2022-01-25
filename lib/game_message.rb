module GameMessage

  def enter_input_message
    puts 'Enter a coordinate to choose a piece to move. (Example: g5)'
  end

  def invalid_input_message
    puts 'Invalid entry. Please try again.'
  end
end