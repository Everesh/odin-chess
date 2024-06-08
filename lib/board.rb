require_relative 'pieces/king'
require_relative 'pieces/queen'
require_relative 'pieces/bishop'
require_relative 'pieces/knight'
require_relative 'pieces/rook'
require_relative 'pieces/pawn'

class Board

    attr_reader :board

    def initialize
        @board = Array.new(8) { Array.new(8) {' '} }
        @board[0] = [Rook.new('white'), Knight.new('white'),
                    Bishop.new('white'), Queen.new('white'),
                    King.new('white'), Bishop.new('white'),
                    Knight.new('white'), Rook.new('white')]
        @board[1] = Array.new(8) { Pawn.new('white') }
        @board[6] = Array.new(8) { Pawn.new('black') }
        @board[7] = [Rook.new('black'), Knight.new('black'),
                    Bishop.new('black'), Queen.new('black'),
                    King.new('black'), Bishop.new('black'),
                    Knight.new('black'), Rook.new('black')]
    end

    def legal_move?(algebraic_notation, active_player)

      # TO DO

    end

    def move(algebraic_notation, active_player)

      # TO DO

    end

    def concluded?

      # TO DO
      # is a pad? || is a mat? || do both players habe insufficient material?

    end

    private

    attr_writer :board
end