require_relative 'piece'

class Bishop < Piece
  WHITE = '♗'.freeze
  BLACK = '♝'.freeze
  MOVES = [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7],
           [1, -1], [2, -2], [3, -3], [4, -4], [5, -5], [6, -6], [7, -7],
           [-1, 1], [-2, 2], [-3, 3], [-4, 4], [-5, 5], [-6, 6], [-7, 7],
           [-1, -1], [-2, -2], [-3, -3], [-4, -4], [-5, -5], [-6, -6], [-7, -7]].freeze

  def self.moves(_ = nil)
    MOVES
  end
end