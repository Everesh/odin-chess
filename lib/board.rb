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

  def legal_move?(algebraic_notation, active_player, history)
    begin
      parse(algebraic_notation, active_player)
    rescue StandardError
      return false
    end
    
    if capture && (board[target[0]][target[1]] == ' ' ? !en_passant?(active_player, history) : false || board[target[0]][target[1]].color == active_player)
      puts '## Invalid capture target'
      return false
    end

    if king_would_be_in_check?
      puts '## Would result in putting your king in check'
      return false
    end

    if enemy_would_be_in_check?
      if would_conclude?
        unless algebraic_notation.match?(/#$/)
          puts '## Tailing mat declaration required \'#\''
          return false
        end
      else
        unless algebraic_notation.match?(/+$/)
          puts '## Tailing check declaration required \'+\''
          return false
        end
      end
    else
      if algebraic_notation.match?(/[#+]$/)
        puts '## Unwarranted tailing check declaration \'+\' or \'#\''
        return false
      end
    end

    if piece == Pawn && (target[0] == 0 || target[0] == 7) && !algebraic_notation.match?(/=/)
      puts '## Promotion not specified'
      return false
    end


    if !capture && board[target[0]][target[1]] != ' '
      puts '## Capture declaration required'
      return false 
    end

    true
  end

  def en_passant?(active_player, history)
    return false if piece != Pawn || board[target[0]][target[1]] != ' '

    column = (target[1] + 'a'.ord).chr
    if active_player == 'white'
      last_move_match = history[-1].match?(/#{column}5$/)
      any_move_match = history.any? { |move| move.match?(/^[a-h]?[1-8]?#{column}6$/) }
    else
      last_move_match = history[-1].match?(/#{column}4$/)
      any_move_match = history.any? { |move| move.match?(/^[a-h]?[1-8]?#{column}3$/) }
    end

    unless last_move_match && !any_move_match
      return false
    end

    true
  end

  def king_would_be_in_check?

    # TO DO

  end

  def enemy_would_be_in_check?

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

  def would_conclude?

    # TO DO
    # Leverage concluded?, make a dube of board, perform the move on it and call concluded? on in

  end

  private

  attr_writer :board
  attr_accessor :piece, :target, :capture, :origin

  def parse(algebraic_notation, active_player)
    @piece = define_piece(algebraic_notation)
    @target = define_target(algebraic_notation)
    @capture = algebraic_notation.match?(/x/)
    @origin = define_origin(algebraic_notation, active_player)
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

  def define_origin(algebraic_notation, active_player)
    origin = define_origin_constrain(algebraic_notation) # [[nil,0-7],[nil, 0-7]]
    return origin if origin.all? { |val| !val.nil? }

    if piece == King
      find_king(origin, active_player)
    elsif piece == Queen
      find_queen(origin, active_player)
    elsif piece == Bishop
      find_bishop(origin, active_player)
    elsif piece == Knight
      find_knight(origin, active_player)
    elsif piece == Rook
      find_rook(origin, active_player)
    elsif piece == Pawn
      find_pawn(origin, active_player)
    end
  end

  def find_king(origin, active_player)
    [[0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1], [1, 0], [1, 1]].each do |move|
      next unless (0..7).include?(target[0] + move[0]) && (0..7).include?(target[1] + move[1])

      next unless (origin[0].nil? || origin[0] == target[0] + move[0]) && (origin[1].nil? || origin[1] == target[1] + move[1])

      contender = board[target[0] + move[0]][target[1] + move[1]]
      return [target[0] + move[0], target[1] + move[1]] if contender.is_a?(King) && contender.color == active_player
    end
    puts '## Failed to find the king'
    raise StandardError
  end

  def find_queen(origin, active_player)
    moves = [[[1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0]],
             [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7]],
             [[0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7]],
             [[-1, 1], [-2, 2], [-3, 3], [-4, 4], [-5, 5], [-6, 6], [-7, 7]],
             [[-1, 0], [-2, 0], [-3, 0], [-4, 0], [-5, 0], [-6, 0], [-7, 0]],
             [[-1, -1], [-2, -2], [-3, -3], [-4, -4], [-5, -5], [-6, -6], [-7, -7]],
             [[0, -1], [0, -2], [0, -3], [0, -4], [0, -5], [0, -6], [0, -7]],
             [[1, -1], [2, -2], [3, -3], [4, -4], [5, -5], [6, -6], [7, -7]]]

    moves.each do |direction|
      direction.each do |move|
        break if target[0] + move[0] < 0 || target[0] + move[0] > 7 || target[1] + move[1] < 0 || target[1] + move[1] > 7

        candidate = board[target[0] + move[0]][target[1] + move[1]]

        next if candidate == ' '

        break unless candidate.is_a?(Queen) && candidate.color == active_player

        next unless (origin[0].nil? || origin[0] == move[0]) && (origin[1].nil? || origin[1] == move[1])

        return [target[0] + move[0], target[1] + move[1]]
      end
    end

    puts '## Failed to find the Queen'
    raise StandardError
  end

  def find_bishop(origin, active_player)
    moves = [[[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7]],
             [[-1, 1], [-2, 2], [-3, 3], [-4, 4], [-5, 5], [-6, 6], [-7, 7]],
             [[-1, -1], [-2, -2], [-3, -3], [-4, -4], [-5, -5], [-6, -6], [-7, -7]],
             [[1, -1], [2, -2], [3, -3], [4, -4], [5, -5], [6, -6], [7, -7]]]

    moves.each do |direction|
      direction.each do |move|
        break if target[0] + move[0] < 0 || target[0] + move[0] > 7 || target[1] + move[1] < 0 || target[1] + move[1] > 7

        candidate = board[target[0] + move[0]][target[1] + move[1]]

        next if candidate == ' '

        break unless candidate.is_a?(Bishop) && candidate.color == active_player

        next unless (origin[0].nil? || origin[0] == move[0]) && (origin[1].nil? || origin[1] == move[1])

        return [target[0] + move[0], target[1] + move[1]]
      end
    end

    puts '## Failed to find the Bishop'
    raise StandardError
  end

  def find_knight(origin, active_player)

    # TO DO

  end

  def find_rook(origin, active_player)
    moves = [[[1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0]],
             [[0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7]],
             [[-1, 0], [-2, 0], [-3, 0], [-4, 0], [-5, 0], [-6, 0], [-7, 0]],
             [[0, -1], [0, -2], [0, -3], [0, -4], [0, -5], [0, -6], [0, -7]]]

    moves.each do |direction|
      direction.each do |move|
        break if target[0] + move[0] < 0 || target[0] + move[0] > 7 || target[1] + move[1] < 0 || target[1] + move[1] > 7

        candidate = board[target[0] + move[0]][target[1] + move[1]]

        next if candidate == ' '

        break unless candidate.is_a?(Rook) && candidate.color == active_player

        next unless (origin[0].nil? || origin[0] == move[0]) && (origin[1].nil? || origin[1] == move[1])

        return [target[0] + move[0], target[1] + move[1]]
      end
    end

    puts '## Failed to find the Rook'
    raise StandardError
  end

  def find_pawn(origin, active_player)

    # TO DO

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
