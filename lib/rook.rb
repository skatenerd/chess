require 'piece'

class Rook < Piece

  def moves(board)
    current_position = board.position_of(self)
    all_positions = row(board) + col(board)

    all_positions.map do |position|
      board.move(current_position, position)
    end
  end

  def castles_with_king(king)
    !opponent?(king)
  end

  private

  def col(board)
    current_position = board.position_of(self)

    below = positions_from_rows(((current_position.row + 1)...Board::SIZE), board)
    above = positions_from_rows((0...current_position.row), board).reverse

    legal_above = take_while_unobstructed(above, board)
    legal_below = take_while_unobstructed(below, board)

    legal_below + legal_above
  end

  def row(board)
    current_position = board.position_of(self)
    to_right = positions_from_columns(((current_position.col + 1)...Board::SIZE), board)
    to_left = positions_from_columns((0...current_position.col), board).reverse

    legal_right = take_while_unobstructed(to_right, board)
    legal_left = take_while_unobstructed(to_left, board)

    legal_left + legal_right
  end

  def take_while_unobstructed(positions, board)
    positions.reduce([]) do |legal_positions, position|
      at_position = board.piece_at(position)
      if at_position == Board::EMPTY && board.squares_all_empty?(legal_positions)
        legal_positions << position
      elsif self.opponent?(at_position) && board.squares_all_empty?(legal_positions)
        legal_positions << position
      else
        legal_positions
      end
    end
  end

  def positions_from_columns(columns, board)
    current_position = board.position_of(self)
    columns.map do |col|
      Position.new(current_position.row, col)
    end
  end

  def positions_from_rows(rows, board)
    current_position = board.position_of(self)
    rows.map do |row|
      Position.new(row, current_position.col)
    end
  end
end


