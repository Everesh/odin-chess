require_relative 'game_pieces/pawn'
require_relative 'game_pieces/rook'
require_relative 'game_pieces/knight'
require_relative 'game_pieces/bishop'
require_relative 'game_pieces/queen'
require_relative 'game_pieces/king'

class Board

  attr_reader :board, :history, :active_player

  def initialize
    @board = Array.new(8) { Array.new(8) }
    @history = []
    @active_player = 'white'
    set
  end

  def set
    8.times do |index|
      board[1][index] = Pawn.new('black')
      board[-2][index] = Pawn.new('white')
      board[2..-3].each { |row| row[index] = ' ' }
      case index
      when 0, 7
        board[0][index] = Rook.new('black')
        board[-1][index] = Rook.new('white')
      when 1, 6
        board[0][index] = Knight.new('black')
        board[-1][index] = Knight.new('white')
      when 2, 5
        board[0][index] = Bishop.new('black')
        board[-1][index] = Bishop.new('white')
      when 3
        board[0][index] = Queen.new('black')
        board[-1][index] = Queen.new('white')
      when 4
        board[0][index] = King.new('black')
        board[-1][index] = King.new('white')
      end
    end
  end

  def print_state
    column_legend = '    A   B   C   D   E   F   G   H    '.freeze
    separator = '  +---+---+---+---+---+---+---+---+  '.freeze
    puts column_legend
    puts separator
    8.times do |row|
      print "#{8 - row} |"
      8.times { |column| print " #{board[row][column] == ' ' ? ' ' : board[row][column].symb} |" }
      puts " #{8 - row}"
      puts separator
    end
    puts column_legend
  end

  private

  attr_writer :board, :history, :active_player

end
