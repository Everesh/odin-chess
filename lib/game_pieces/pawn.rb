require_relative 'piece'

class Pawn < Piece
  WHITE = '♙'.freeze
  BLACK = '♟︎'.freeze
  MOVES = [[0,1]].freeze
end