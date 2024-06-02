require_relative 'piece'

class King < Piece
  WHITE = '♔'.freeze
  BLACK = '♚'.freeze
  MOVES = [[0, 1], [0, -1], [1, 0], [-1, 0]].freeze

  def self.moves(_ = nil)
    MOVES
  end
end