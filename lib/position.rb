class Position
  attr_reader :row, :col
  def initialize(row, col)
    @row = row
    @col = col
  end

  def ==(other)
    return (other.row == row) && (other.col == col)
  end
end

