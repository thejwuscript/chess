# frozen_string_literal: true

require_relative 'game_message'

class HumanPlayer < Player
  include GameMessage
  
  def initialize(name, color = nil)
    super
  end

  def input
    loop do
      input = gets.chomp.upcase
      return input if input.match?(/^[A-H][1-8]$|^B$|^S$|^Q$/)

      invalid_input_message
      rescue ArgumentError
        invalid_input_message
    end
  end

  def promotion_choice
    promotion_message
    loop do
      input = gets.chomp
      return input.to_i if input.match?(/^[1-4]$/)
  
      invalid_input_message
    end
  end
end
