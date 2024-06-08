require_relative 'piece'

class Bishop < Piece
  attr_reader :chr

  def initialize(color)
    super
    @chr = color == 'white' ? '♗' : '♝'
  end
end
