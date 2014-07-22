require 'piece'
require 'threat'

class King < Piece
  class EastCastle
    def initialize(king, board)
      @king = king
      @board = board
    end

    def possible_castles
      castle_at_row(7) + castle_at_row(0)
    end

    private

    attr_reader :board, :king

    def castle_at_row(row)
      legal_castle = rook_in_required_position(row) \
        && king_in_required_position(row) \
        && empty_castle_path(row) \
        && safe_castle_path(row) \
        && king_has_not_moved \
        && rook_has_not_moved(row)

      if legal_castle
        return [execute_castle(row)]
      end
      []
    end

    def execute_castle(row)
      new_king_position = Position.new(row,6)
      new_rook_position = Position.new(row,5)

      board.move(king_position, new_king_position).move(required_rook_position(row), new_rook_position)
    end

    def king_has_not_moved()
      !board.moved_pieces.include?(king)
    end

    def rook_has_not_moved(row)
      rook = board.piece_at(required_rook_position(row))
      !board.moved_pieces.include?(rook)
    end

    def safe_castle_path(row)
      between_spaces = castle_path(row)
      safe_travel = between_spaces.none? do |position|
        Threat.for_square(king, position, board)
      end
    end

    def empty_castle_path(row)
      between_spaces = castle_path(row)
      board.squares_all_empty?(between_spaces)
    end

    def king_in_required_position(row)
      king_position == required_king_position(row)
    end

    def rook_in_required_position(row)
      board.piece_at(required_rook_position(row)).castles_with_king(king)
    end

    def required_rook_position(row)
      Position.new(row, 7)
    end

    def required_king_position(row)
      Position.new(row, 4)
    end

    def king_position
      board.position_of(king)
    end

    def castle_path(row)
      low, high = [required_king_position(row).col, required_rook_position(row).col].sort
      ((low + 1)...high).map do |col|
        Position.new(row, col)
      end
    end
  end
end


