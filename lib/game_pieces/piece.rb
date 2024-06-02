class Piece

  attr_reader :color

  def initialize(color)
    @color = color
  end

  def symb
    color == 'white' ? self.class::WHITE : self.class::BLACK
  end
end