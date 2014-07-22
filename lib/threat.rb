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
