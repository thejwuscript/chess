module BoardDisplay

  def show_board
    puts ''
    colorize_board.each_with_index do |row, index|
      numbers_column(index)
      row.each { |square| print square }
      print "\n"
    end
    letter_coordinates
  end

  def colorize_board
    grid.map.with_index do |row, row_ind|
      row.map.with_index do |piece, col_ind|
        colorize_square(piece, row_ind, col_ind)
      end
    end
  end

  def colorize_square(piece, row, column)
    if piece.nil?
      default_color(piece, row, column)
    elsif piece.selected
      green_square(piece)
    else
      default_color(piece, row, column)
    end
  end

  def default_color(piece, row, column)
    if row.even? && column.even? || row.odd? && column.odd?
      white_square(piece)
    else
      black_square(piece)
    end
  end

  def green_square(piece)
    "\e[48;5;70m #{piece.symbol} \e[0m"
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
    piece.nil? ? "\e[48;5;248m   \e[0m" : "\e[48;5;248m #{piece.symbol} \e[0m"
  end

  def black_square(piece)
    piece.nil? ? "\e[48;5;240m   \e[0m" : "\e[48;5;240m #{piece.symbol} \e[0m"
  end

  def letter_coordinates
    puts "     #{('a'..'h').to_a.join('  ')}"
  end

  def numbers_column(index)
    numbers = (1..8).to_a.reverse
    print "  #{numbers[index]} "
  end
end