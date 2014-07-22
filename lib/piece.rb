class Piece
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def opponent?(other)
    return (other.color != color)
  end

  def castles_with_king(king)
    false
  end
end
