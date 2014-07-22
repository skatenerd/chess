require 'chess'
require 'rspec'

describe "Acceptance" do
  describe "moving" do
    describe "rook" do
      it "can move unobstructed on ranks and files" do
        board = Board.new
        rook = Rook.new(Board::BLACK)
        board.place(Position.new(1, 5), rook)
        accessible_boards = rook.moves(board)

				expect(accessible_boards).to include(an_object_satisfying do |potential_board|
          potential_board.piece_at(Position.new(1,3)) == rook
        end)

				expect(accessible_boards).to include(an_object_satisfying do |potential_board|
          potential_board.piece_at(Position.new(1,4)) == rook
        end)

				expect(accessible_boards).to include(an_object_satisfying do |potential_board|
          potential_board.piece_at(Position.new(0,5)) == rook
        end)
      end

      it "cannot move into its current space" do
        board = Board.new
        rook = Rook.new(Board::BLACK)
        board.place(Position.new(1, 5), rook)
        accessible_boards = rook.moves(board)

				expect(accessible_boards).not_to include(an_object_satisfying do |potential_board|
          potential_board.piece_at(Position.new(1,5)) == rook
        end)
      end

			it "cannot move past obstructed space" do
        board = Board.new
        black_rook = Rook.new(Board::BLACK)
        white_rook = Rook.new(Board::WHITE)
        other_white_rook = Rook.new(Board::WHITE)

        board.place(Position.new(1, 1), black_rook)
        board.place(Position.new(1, 5), white_rook)
        board.place(Position.new(5, 1), other_white_rook)
        accessible_boards = black_rook.moves(board)

				expect(accessible_boards).not_to include(an_object_satisfying do |potential_board|
          potential_board.piece_at(Position.new(1,6)) == black_rook
        end)

				expect(accessible_boards).not_to include(an_object_satisfying do |potential_board|
          potential_board.piece_at(Position.new(6,1)) == black_rook
        end)
      end

			it "cannot move past obstructed space" do
        board = Board.new
        black_rook = Rook.new(Board::BLACK)
				teammate_black_rook = Rook.new(Board::BLACK)
        white_rook = Rook.new(Board::WHITE)

        board.place(Position.new(1, 4), black_rook)
        board.place(Position.new(1, 6), teammate_black_rook)
        board.place(Position.new(1, 0), white_rook)
        accessible_boards = black_rook.moves(board)
      
				expect(accessible_boards).to include(an_object_satisfying do |potential_board|
          potential_board.piece_at(Position.new(1,0)) == black_rook
        end)

				expect(accessible_boards).not_to include(an_object_satisfying do |potential_board|
          potential_board.piece_at(Position.new(1,6)) == black_rook
        end)
      end
    end
		
		describe "king" do
			it "can move one square in any direction" do
        board = Board.new
        king = King.new(Board::BLACK)
        board.place(Position.new(2, 2), king)
				accessible_boards = king.moves(board)

				expect(accessible_boards).to include(an_object_satisfying do |potential_board|
          potential_board.piece_at(Position.new(3,3)) == king
        end)

				expect(accessible_boards).to include(an_object_satisfying do |potential_board|
          potential_board.piece_at(Position.new(1,1)) == king
        end)

				expect(accessible_boards).to include(an_object_satisfying do |potential_board|
          potential_board.piece_at(Position.new(2,3)) == king
        end)

				expect(accessible_boards).to include(an_object_satisfying do |potential_board|
          potential_board.piece_at(Position.new(2,1)) == king
        end)

				expect(accessible_boards).to include(an_object_satisfying do |potential_board|
          potential_board.piece_at(Position.new(1,2)) == king
        end)
      end

			it "cannot move off the board" do
        board = Board.new
        king = King.new(Board::BLACK)
        board.place(Position.new(0, 0), king)
				accessible_boards = king.moves(board)
				expect(accessible_boards.count).to eq(3)
      end

			it "cannot move into check" do
        board = Board.new
        king = King.new(Board::BLACK)
				rook = Rook.new(Board::WHITE)
        board.place(Position.new(0, 0), king)
        board.place(Position.new(5, 1), rook)

				accessible_boards = king.moves(board)

				expect(accessible_boards).not_to include(an_object_satisfying do |potential_board|
          potential_board.piece_at(Position.new(0,1)) == king
        end)
      end

			describe "castling" do
				it "black king can castle on the left side" do
					board = Board.new
					king = King.new(Board::BLACK)
					rook = Rook.new(Board::BLACK)
					board.place(Position.new(0, 4), king)
					board.place(Position.new(0, 7), rook)

					accessible_boards = king.moves(board)

					expect(accessible_boards).to include(an_object_satisfying do |potential_board|
						potential_board.piece_at(Position.new(0, 6)) == king
						potential_board.piece_at(Position.new(0, 5)) == rook
					end)
					expect(accessible_boards.count).to eq(6)
				end

				it "black king cannot castle with enemy rook" do
					board = Board.new
					king = King.new(Board::BLACK)
					rook = Rook.new(Board::WHITE)
					board.place(Position.new(0, 4), king)
					board.place(Position.new(0, 7), rook)

					accessible_boards = king.moves(board)

					expect(accessible_boards).not_to include(an_object_satisfying do |potential_board|
						potential_board.piece_at(Position.new(0, 6)) == king
						potential_board.piece_at(Position.new(0, 5)) == rook
					end)
				end

				it "black king cannot castle through pieces" do
					board = Board.new
					king = King.new(Board::BLACK)
					blocking_rook = Rook.new(Board::BLACK)
					rook = Rook.new(Board::BLACK)
					board.place(Position.new(0, 4), king)
					board.place(Position.new(0, 5), blocking_rook)
					board.place(Position.new(0, 7), rook)

					accessible_boards = king.moves(board)

					expect(accessible_boards).not_to include(an_object_satisfying do |potential_board|
						potential_board.piece_at(Position.new(0, 6)) == king
						potential_board.piece_at(Position.new(0, 5)) == rook
					end)
				end

				it "black king cannot castle through check" do
					board = Board.new
					king = King.new(Board::BLACK)
					checking_rook = Rook.new(Board::WHITE)
					rook = Rook.new(Board::BLACK)
					board.place(Position.new(0, 4), king)
					board.place(Position.new(5, 5), checking_rook)
					board.place(Position.new(0, 7), rook)

					accessible_boards = king.moves(board)

					expect(accessible_boards).not_to include(an_object_satisfying do |potential_board|
						potential_board.piece_at(Position.new(0, 6)) == king
						potential_board.piece_at(Position.new(0, 5)) == rook
					end)
				end

				#what if the rook moves?
				it "black king cannot castle after it has moved" do
					board = Board.new
					king = King.new(Board::BLACK)
					rook = Rook.new(Board::BLACK)
					board.place(Position.new(0, 4), king)
					board.place(Position.new(0, 7), rook)
					board = board.move(Position.new(0,4), Position.new(1,4))
					board = board.move(Position.new(1,4), Position.new(0,4))

					accessible_boards = king.moves(board)

					expect(accessible_boards).not_to include(an_object_satisfying do |potential_board|
						potential_board.piece_at(Position.new(0, 6)) == king
						potential_board.piece_at(Position.new(0, 5)) == rook
					end)
				end

				it "white king can castle on the right side" do
					board = Board.new
					king = King.new(Board::WHITE)
					rook = Rook.new(Board::WHITE)
					board.place(Position.new(7, 4), king)
					board.place(Position.new(7, 7), rook)

					accessible_boards = king.moves(board)

					expect(accessible_boards).to include(an_object_satisfying do |potential_board|
						potential_board.piece_at(Position.new(7, 6)) == king
						potential_board.piece_at(Position.new(7, 5)) == rook
					end)
					expect(accessible_boards.count).to eq(6)
				end
			end
		end
  end
end
