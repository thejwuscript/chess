# frozen_string_literal: true

require_relative '../lib/game'
require_relative '../lib/board'
require_relative '../lib/rook'
require_relative '../lib/knight'
require_relative '../lib/bishop'
require_relative '../lib/queen'
require_relative '../lib/king'
require_relative '../lib/pawn'

RSpec.describe Game do
  subject(:game) { described_class.new }
  
  describe '#place_on_board' do
    context 'when a piece is initialized' do
      let(:piece) { double('piece', position: 'E2') }
      
      it 'sends a message to board to include the piece in @grid' do
        board = game.board
        position = piece.position
        expect(board).to receive(:set_piece_at).with(position, piece)
        game.place_on_board(piece)
      end
    end
  end

  describe '#create_promoted_pieces' do
    it 'returns 8 pieces of promoted objects' do
      array = [Rook, Rook, Knight, Knight, Bishop, Bishop, Queen, King]
      result = game.create_promoted_pieces.map { |obj| obj.class }
      expect(result).to eql(array)
    end
  end

  describe '#assign_color' do
    it 'returns an array of pieces with assigned colors' do
      pieces_array = Array.new(8, Piece.new)
      new_array = game.assign_color(pieces_array, 'W')
      result = new_array.none? { |piece| piece.color.nil? }
      expect(result).to eql(true)
    end
  end

  describe '#create_pawns' do
    it 'returns an array of eight objects' do
      result = game.create_pawns.size
      expect(result).to eql(8)
    end

    it 'all objects in the array are Pawns' do
      array = game.create_pawns
      result = array.all? { |piece| piece.is_a? Pawn }
      expect(result).to eql(true)
    end
  end

end