require 'piece'

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
