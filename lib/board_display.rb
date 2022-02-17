module BoardDisplay

  #def show_board
    #puts ''
    #grid.each_with_index do |row, row_index|
    #  numbers_column(row_index)
    #  row_index.even? ? white_black_row(row) : black_white_row(row)
    #end
    #letter_coordinates
  #end

  def show_board
    puts ''
    default_colors.each_with_index do |row, index|
      numbers_column(index)
      row.each { |square| print square }
      print "\n"
    end
    letter_coordinates
  end

  def default_colors
    @display = grid.map.with_index do |row, row_index|
      row_index.even? ? white_black_row(row) : black_white_row(row)
    end
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