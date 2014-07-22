require 'set'

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

class Board
  class NullPiece < Piece
    def color
    end

    def moves(board)
      []
    end
  end

  BLACK = :black
  WHITE = :white
  SIZE = 8
  EMPTY = NullPiece.new(nil)
  
  attr_accessor :state, :moved_pieces
  def initialize
    @moved_pieces = []
    @state = (0...SIZE).map do
      (0...SIZE).map do
        EMPTY
      end
    end
  end

  def on_board(position)
    row_ok = position.row >= 0 && position.row < SIZE
    col_ok = position.col >= 0 && position.col < SIZE
    row_ok && col_ok
  end

  def squares_all_empty?(squares)
    squares.all? do |square|
      piece_at(square) == EMPTY
    end
  end

  def place(position, piece)
    @state[position.row][position.col] = piece
  end

  def move(from, to)
    new_board = Board.clone(self)
    if from == to
      return new_board
    end
    new_board.moved_pieces << piece_at(from)
    new_board.place(to, piece_at(from))
    new_board.place(from, EMPTY)
    return new_board
  end

  def position_of(target)
    state.each_with_index do |row, row_index|
      row.each_with_index do |piece, col_index|
        if piece_at(Position.new(row_index, col_index)) == target
          return Position.new(row_index, col_index)
        end
      end
    end
  end

  def piece_at(position)
    return @state[position.row][position.col]
  end

  def pieces
    state.flatten
  end

  private

  def self.clone(board)
    new_board = Board.new()
    state_clone = board.state.map do |row|
      row.dup
    end
    new_board.state = state_clone
    new_board
  end

end

class Threat
  def self.for_square(mover, square, board)
    enemies = board.pieces.select do |piece|
      mover.opponent?(piece)
    end

    enemies.any? do |piece|
      potential_boards = piece.moves(board)
      potential_boards.any? do |potential_board|
        potential_board.piece_at(square) == piece
      end
    end
  end
end

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
        && king_has_not_moved

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

