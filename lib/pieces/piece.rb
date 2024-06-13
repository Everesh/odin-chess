class Piece
  attr_reader :color

  def initialize(color)
    @color = color
    @has_made_a_move = false
  end

  def moved?
    has_made_a_move
  end

  def register_move
    self.has_made_a_move = true
  end

  private

  attr_accessor :has_made_a_move
end
