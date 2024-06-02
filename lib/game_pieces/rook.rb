require_relative 'piece'

class Rook < Piece
  WHITE = '♖'.freeze
  BLACK = '♜'.freeze
  MOVES = [[0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7],
           [0, -1], [0, -2], [0, -3], [0, -4], [0, -5], [0, -6], [0, -7],
           [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0],
           [-1, 0], [-2, 0], [-3, 0], [-4, 0], [-5, 0], [-6, 0], [-7, 0]].freeze
  
  def self.moves(_ = nil)
    MOVES
  end
end