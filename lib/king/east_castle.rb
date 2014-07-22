require 'piece'
require 'threat'

class King < Piece
  class Castle

  end

  class EastCastle < Castle
    def initialize(king, board)
      @king = king
      @board = board
    end

    def possible_castles
      legal_castle = rook_in_required_position \
        && king_in_required_position \
        && empty_castle_path \
        && safe_castle_path \
        && king_has_not_moved \
        && rook_has_not_moved

      if legal_castle
        return [execute_castle]
      end
      []
    end

    private

    attr_reader :board, :king

    def row
      king_position.row
    end

    def execute_castle
      board.move(king_position, destination_king_position).move(required_rook_position, destination_rook_position)
    end

    def king_has_not_moved
      !board.moved_pieces.include?(king)
    end

    def rook_has_not_moved
      rook = board.piece_at(required_rook_position)
      !board.moved_pieces.include?(rook)
    end

    def safe_castle_path
      between_spaces = castle_path
      safe_travel = between_spaces.none? do |position|
        Threat.for_square(king, position, board)
      end
    end

    def empty_castle_path
      between_spaces = castle_path
      board.squares_all_empty?(between_spaces)
    end

    def king_in_required_position
      king_position == required_king_position
    end

    def rook_in_required_position
      board.piece_at(required_rook_position).castles_with_king(king)
    end

    def required_rook_position
      Position.new(row, 7)
    end

    def required_king_position
      Position.new(row, 4)
    end

    def destination_rook_position
      new_rook_position = Position.new(row,5)
    end

    def destination_king_position
      new_king_position = Position.new(row,6)
    end

    def king_position
      board.position_of(king)
    end

    def castle_path
      low, high = [required_king_position.col, required_rook_position.col].sort
      ((low + 1)...high).map do |col|
        Position.new(row, col)
      end
    end
  end
end


