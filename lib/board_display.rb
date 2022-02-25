# frozen_string_literal: true

module BoardDisplay
  def show_board
    system('clear')
    puts "             \e[1m\e[4mCHESS\e[0m"
    puts ''
    colorize_board.each_with_index do |row, index|
      numbers_column(index)
      row.each { |square| print square }
      print "\n"
    end
    letter_coordinates
    puts ''
  end

  def show_board_with_targeted_piece(target_ary, player)
    @attacking_arrays = occupied?(target_ary) ? [target_ary] : []
    show_board_with_delay(player)
  end

  def show_board_with_delay(player)
    show_board
    puts "Computer's turn..." if player.is_a?(ComputerPlayer)
    sleep 0.8
    system("tput cuu1 && tput el") if player.is_a?(ComputerPlayer)
  end

  def show_board_on_quit
    @attacking_arrays = []
    @origin_ary = nil
    clear_piece_selection
    show_board
  end

  def clear_piece_selection
    grid.flatten.compact.each { |sq| sq.selected = false }
  end

  def show_color_guides(player, piece, examiners = nil)
    clear_piece_selection
    piece.update_selected_value(true)
    @origin_ary = piece.position_to_array
    move_hints(examiners) if player.is_a?(HumanPlayer)
    
    show_board
  end

  def move_hints(examiners)
    @attacking_arrays = examiners.map { |examiner| position_to_array(examiner.target) }
  end

  private

  def colorize_board
    grid.map.with_index do |row, row_ind|
      row.map.with_index do |piece, col_ind|
        colorize_square(piece, row_ind, col_ind)
      end
    end
  end

  def colorize_square(piece, row, column)
    if piece.nil? && origin_ary == [row, column]
      green_square(piece)
    elsif piece.nil?
      default_color(piece, row, column)
    elsif piece.selected
      green_square(piece)
    elsif piece && attacking_arrays.include?([row, column])
      red_square(piece)
    else
      default_color(piece, row, column)
    end
  end

  def default_color(piece, row, column)
    if row.even? && column.even? || row.odd? && column.odd?
      attacking_arrays.include?([row, column]) ? dot_white_square : white_square(piece)
    else
      attacking_arrays.include?([row, column]) ? dot_black_square : black_square(piece)
    end
  end

  def green_square(piece)
    piece.nil? ? "\e[48;5;143m   \e[0m" : "\e[48;5;143m #{piece.symbol} \e[0m"
  end

  def red_square(piece)
    piece.nil? ? "\e[48;5;174m   \e[0m" : "\e[48;5;174m #{piece.symbol} \e[0m"
  end

  def dot_white_square
    selected = grid.flatten.compact.find { |piece| piece.selected }
    symbol = selected.color == 'W' ? "\e[38;5;15m\u25CF" : "\e[38;5;0m\u25CF"
    "\e[48;5;248m #{symbol} \e[0m"
  end

  def dot_black_square
    selected = grid.flatten.compact.find { |piece| piece.selected }
    symbol = selected.color == 'W' ? "\e[38;5;15m\u25CF" : "\e[38;5;0m\u25CF"
    "\e[48;5;240m #{symbol} \e[0m"
  end

  def white_black_row(row)
    row.map.with_index do |piece, column|
      column.even? ? white_square(piece) : black_square(piece)
    end
  end
  
  def black_white_row(row)
    row.map.with_index do |piece, column|
      column.even? ? black_square(piece) : white_square(piece)
    end
  end

  def white_square(piece)
    piece.nil? ? "\e[48;5;249m   \e[0m" : "\e[48;5;249m #{piece.symbol} \e[0m"
  end

  def black_square(piece)
    piece.nil? ? "\e[48;5;242m   \e[0m" : "\e[48;5;242m #{piece.symbol} \e[0m"
  end

  def letter_coordinates
    puts "     #{('a'..'h').to_a.join('  ')}"
  end

  def numbers_column(index)
    numbers = (1..8).to_a.reverse
    print "  #{numbers[index]} "
  end
end