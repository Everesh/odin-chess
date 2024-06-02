require_relative 'piece'

class Knight < Piece
  WHITE = '♘'.freeze
  BLACK = '♞'.freeze
  MOVES = [[1, 2], [-1, 2],
           [-2, 1], [-2, -1],
           [1, -2], [-1, -2],
           [2, 1], [2, -1]].freeze
end