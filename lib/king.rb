require 'piece'
require 'king/east_castle'

class King < Piece
  def moves(board)
    current_position = board.position_of(self)
    one_away_moves = one_away_moves(board)
    legal_moves = one_away_moves.select do |position|
      board.on_board(position)
    end

    not_threatened = legal_moves.reject do |square|
      Threat.for_square(self, square, board)
    end

    vanilla_moves = not_threatened.map do |position|
      board.move(current_position, position)
    end

    vanilla_moves + EastCastle.new(self, board).possible_castles
  end

  private

  def one_away_moves(board)
    current_position = board.position_of(self)
    three_by_three_square = (current_position.row - 1..current_position.row + 1).map do |row|
      (current_position.col - 1..current_position.col + 1).map do |col|
        Position.new(row, col)
      end
    end.flatten

    three_by_three_square.reject do |position|
      position == current_position
    end
  end
end
