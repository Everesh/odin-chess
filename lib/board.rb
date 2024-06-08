require_relative 'pieces/king'
require_relative 'pieces/queen'
require_relative 'pieces/bishop'
require_relative 'pieces/knight'
require_relative 'pieces/rook'
require_relative 'pieces/pawn'

class Board

    def initialize
        @board = Array.new(8) { Array.new(8) {' '} }
        @board[0] = [Rook.new('white'), Knight.new('white'),
                    Bishop.new('white'), Queen.new('white'),
                    King.new('white'), Bishop.new('white'),
                    Knight.new('white'), Rook.new('white')]
        @board[1] = array.new(8) { Pawn.new('white') }
        @board[6] = array.new(8) { Pawn.new('black') }
        @board[7] = [Rook.new('black'), Knight.new('black'),
                    Bishop.new('black'), Queen.new('black'),
                    King.new('black'), Bishop.new('black'),
                    Knight.new('black'), Rook.new('black')]
    end
end