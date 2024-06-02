require_relative 'piece'
require_relative 'rook'
require_relative 'bishop'

class Queen < Piece
  WHITE = '♕'.freeze
  BLACK = '♛'.freeze
  MOVES = (Rook::MOVES + Bishop::MOVES).freeze
end