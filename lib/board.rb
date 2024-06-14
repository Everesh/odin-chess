require_relative 'pieces/king'
require_relative 'pieces/queen'
require_relative 'pieces/bishop'
require_relative 'pieces/knight'
require_relative 'pieces/rook'
require_relative 'pieces/pawn'

class Board
  attr_reader :board

  def initialize
    @board = Array.new(8) { Array.new(8) { ' ' } }
    @board[0] = [Rook.new('white'), Knight.new('white'),
                 Bishop.new('white'), Queen.new('white'),
                 King.new('white'), Bishop.new('white'),
                 Knight.new('white'), Rook.new('white')]
    @board[1] = Array.new(8) { Pawn.new('white') }
    @board[6] = Array.new(8) { Pawn.new('black') }
    @board[7] = [Rook.new('black'), Knight.new('black'),
                 Bishop.new('black'), Queen.new('black'),
                 King.new('black'), Bishop.new('black'),
                 Knight.new('black'), Rook.new('black')]
  end

  def legal_move?(algebraic_notation, active_player, _history)
    parse(algebraic_notation, active_player)
    true
    # TO DO
  end

  def move(algebraic_notation, active_player)
    return castle(algebraic_notation, active_player) if algebraic_notation.match?(/^O-O(-O)?$/)

    parse(algebraic_notation, active_player)
    en_pasant if piece == Pawn && capture && board[target[0]][target[1]] == ' '
    board[target[0]][target[1]] = board[origin[0]][origin[1]]
    board[origin[0]][origin[1]] = ' '
    promote(algebraic_notation, active_player) if algebraic_notation.match?(/=/)
    board[target[0]][target[1]].register_move
  end

  def concluded?
    # TO DO
    # is a pad? || is a mat? || do both players habe insufficient material?
  end

  private

  attr_writer :board
  attr_accessor :piece, :target, :capture, :origin

  def parse(algebraic_notation, _active_player)
    @piece = define_piece(algebraic_notation)
    @target = define_target(algebraic_notation)
    @capture = algebraic_notation.match?(/x/)
    @origin = define_origin(algebraic_notation)
  end

  def define_piece(str)
    case str[0]
    when 'K' then King
    when 'Q' then Queen
    when 'B' then Bishop
    when 'N' then Knight
    when 'R' then Rook
    else Pawn end
  end

  def define_target(str)
    target = [nil, nil]
    restrains = str.match(/^[KQBNR]?[a-h]?[1-8]?x?([a-h][1-8])/).captures[0]
    restrains.each_char do |element|
      if element.match?(/[a-h]/)
        target[1] = element.ord - 'a'.ord
      else
        target[0] = element.to_i - 1
      end
    end
    target
  end

  def define_origin(str)
    define_origin_constrain(str)

    # TO DO, if origin is not explicit in the notation
  end

  def define_origin_constrain(str)
    origin = [nil, nil]
    restrains = str.match(/^[KQBNR]?([a-h]?[1-8]?)?x?[a-h][1-8]/).captures[0]
    restrains.each_char do |element|
      if element.match?(/[a-h]/)
        origin[1] = element.ord - 'a'.ord
      else
        origin[0] = element.to_i - 1
      end
    end
    origin
  end

  def castle(algebraic_notation, active_player)
    row = active_player == 'white' ? 0 : 7
    if algebraic_notation.match?(/^O-O$/)
      board[row][6] = board[row][4]
      board[row][5] = board[row][7]
      board[row][7] = board[row][4] = ' '
      board[row][6].register_move
      board[row][5].register_move
    else
      board[row][2] = board[row][4]
      board[row][3] = board[row][0]
      board[row][0] = board[row][4] = ' '
      board[row][2].register_move
      board[row][3].register_move
    end
  end

  def promote(algebraic_notation, active_player)
    case algebraic_notation.match(/=([QRBN])/).captures[0]
    when 'Q' then board[target[0]][target[1]] = Queen.new(active_player)
    when 'B' then board[target[0]][target[1]] = Bishop.new(active_player)
    when 'N' then board[target[0]][target[1]] = Knight.new(active_player)
    when 'R' then board[target[0]][target[1]] = Rook.new(active_player)
    end
  end

  def en_pasant
    puts 'en passanting'
    if target[0] == 2 # En passating white pieces
      board[target[0] + 1][target[1]] = ' '
    else # En passating black pieces
      board[target[0] - 1][target[1]] = ' '
    end
  end
end
