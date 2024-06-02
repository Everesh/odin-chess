require_relative 'piece'

class Pawn < Piece
  WHITE = '♙'.freeze
  BLACK = '♟︎'.freeze
  MOVES = [[1,0]].freeze
  CAPTURE_MOVES = [[1,1], [1,-1]]

  def self.moves(capture = false)
    capture ? CAPTURE_MOVES : MOVES
  end
end