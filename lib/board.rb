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
    return can_castle?(algebraic_notation, active_player) if algebraic_notation.match?(/^O-O(-O)?$/)

    begin
      parse(algebraic_notation, active_player)
    rescue StandardError
      return false
    end
    
    if capture && (board[target[0]][target[1]] == ' ' ? !en_passant?(active_player, history) : false || board[target[0]][target[1]].color == active_player)
      puts '## Invalid capture target'
      return false
    end

    if king_would_be_in_check?(algebraic_notation, active_player)
      puts '## Would result in putting your king in check'
      return false
    end

    if enemy_would_be_in_check?(algebraic_notation, active_player)
      if would_conclude?(algebraic_notation, active_player, history)
        unless algebraic_notation.end_with?('#')
          puts '## Tailing mat declaration required \'#\''
          return false
        end
      else
        unless algebraic_notation.end_with?('+')
          puts '## Tailing check declaration required \'+\''
          return false
        end
      end
    else
      if algebraic_notation.end_with?('#') || algebraic_notation.end_with?('+')
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

  def move(algebraic_notation, active_player)
    return castle(algebraic_notation, active_player) if algebraic_notation.match?(/^O-O(-O)?$/)

    parse(algebraic_notation, active_player)
    en_pasant if piece == Pawn && capture && board[target[0]][target[1]] == ' '
    board[target[0]][target[1]] = board[origin[0]][origin[1]]
    board[origin[0]][origin[1]] = ' '
    promote(algebraic_notation, active_player) if algebraic_notation.match?(/=/)
    board[target[0]][target[1]].register_move
  end

  def concluded?(history)
    insufficient_material? || checkmate?(history) || stalemate?(history) || threefold_repetition?(history) || fifty_move_rule?(history)
  end

  private

  attr_writer :board
  attr_accessor :piece, :target, :capture, :origin

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

  def checkmate?(history)
    return false if is_safe?(king_doko(history.length.odd? ? 'black' : 'white'), history.length.odd? ? 'black' : 'white')

    !way_out?(history.length.odd? ? 'black' : 'white')
  end

  def stalemate?(history)
    return false unless is_safe?(king_doko(history.length.odd? ? 'black' : 'white'), history.length.odd? ? 'black' : 'white')

    !way_out?(history.length.odd? ? 'black' : 'white')
  end

  def way_out?(rescuey)
    pieces = []
    board.each_with_index { |line, row| line.each_with_index { |item, column| pieces << [item, row, column] if item != ' ' && item.color == rescuey } }
    until pieces.empty?
      testing = pieces.pop
      return true if has_legal_move?(testing)
    end
    false
  end
  
  def has_legal_move?(testee)
    moveset = []
    if testee[0].is_a?(King)
      [[[1, 0]], [[1, 1]], [[0, 1]], [[-1, 1]], [[-1, 0]], [[-1, -1]], [[0, -1]], [[1, -1]]].each { |move_block| moveset << move_block }
    elsif testee[0].is_a?(Rook)
      [[[1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0]],
       [[-1, 0], [-2, 0], [-3, 0], [-4, 0], [-5, 0], [-6, 0], [-7, 0]],
       [[0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7]],
       [[0, -1], [0, -2], [0, -3], [0, -4], [0, -5], [0, -6], [0, -7]]].each { |move_block| moveset << move_block }
    elsif testee[0].is_a?(Bishop)
      [[[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7]],
       [[-1, 1], [-2, 2], [-3, 3], [-4, 4], [-5, 5], [-6, 6], [-7, 7]],
       [[1, -1], [2, -2], [3, -3], [4, -4], [5, -5], [6, -6], [7, -7]],
       [[-1, -1], [-2, -2], [-3, -3], [-4, -4], [-5, -5], [-6, -6], [-7, -7]]].each { |move_block| moveset << move_block }
    elsif testee[0].is_a?(Queen)
      [[[1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0]],
       [[-1, 0], [-2, 0], [-3, 0], [-4, 0], [-5, 0], [-6, 0], [-7, 0]],
       [[0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7]],
       [[0, -1], [0, -2], [0, -3], [0, -4], [0, -5], [0, -6], [0, -7]],
       [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7]],
       [[-1, 1], [-2, 2], [-3, 3], [-4, 4], [-5, 5], [-6, 6], [-7, 7]],
       [[1, -1], [2, -2], [3, -3], [4, -4], [5, -5], [6, -6], [7, -7]],
       [[-1, -1], [-2, -2], [-3, -3], [-4, -4], [-5, -5], [-6, -6], [-7, -7]]].each { |move_block| moveset << move_block }
    elsif testee[0].is_a?(Knight)
      [[[2, 1]], [[2, -1]], [[1, 2]], [[-1, 2]], [[-2, 1]], [[-2, -1]], [[1, -2]], [[-1, -2]]].each { |move_block| moveset << move_block }
    elsif testee[0].is_a?(Pawn)
      if testee[0].color == 'white'
        moveset << [[1, 0]]
        moveset << [[1, 1]] if testee[2] + 1 <= 7 && board[testee[1] + 1][testee[2] + 1] != ' ' && board[testee[1] + 1][testee[2] + 1].color == 'black'
        moveset << [[1, -1]] if testee[2] - 1 >= 0 && board[testee[1] + 1][testee[2] - 1] != ' ' && board[testee[1] + 1][testee[2] - 1].color == 'black'
      else
        moveset << [[-1, 0]]
        moveset << [[-1, 1]] if testee[2] + 1 <= 7 && board[testee[1] - 1][testee[2] + 1] != ' ' && board[testee[1] - 1][testee[2] + 1].color == 'white'
        moveset << [[-1, -1]] if testee[2] - 1 >= 0 && board[testee[1] - 1][testee[2] - 1] != ' ' && board[testee[1] - 1][testee[2] - 1].color == 'white'
      end
    else
      puts "### Piece moveset not found"
      raise StandardError
    end

    moveset.each do |moves|
      until moves.empty?
        move = moves.shift
        break if testee[1] + move[0] > 7 || testee[1] + move[0] < 0 || testee[2] + move[1] > 7 || testee[2] + move[1] < 0
        break if board[testee[1] + move[0]][testee[2] + move[1]] != " " && board[testee[1] + move[0]][testee[2] + move[1]].color == testee[0].color

        board_copy = deep_copy(board)
        board[testee[1] + move[0]][testee[2] + move[1]] = board[testee[1]][testee[2]]
        board[testee[1]][testee[2]] = ' '
        is_an_out = is_safe?(king_doko(testee[0].color), testee[0].color)
        self.board = board_copy

        return true unless is_an_out

        break if board[testee[1] + move[0]][testee[2] + move[1]] != " " && board[testee[1] + move[0]][testee[2] + move[1]].color != testee[0].color
      end
    end

    return false
  end

  def insufficient_material?
    pieces = board.flatten.reject { |cell| cell == ' ' }
    return true if pieces.all? { |piece| piece.is_a?(King) }
    return true if pieces.size == 3 && pieces.one? { |piece| piece.is_a?(Bishop) }
    return true if pieces.size == 3 && pieces.one? { |piece| piece.is_a?(Knight) }
    false
  end

  def fifty_move_rule?(history)
    return false if history.length < 50

    !history.any? { |str| str.include?('x') }
  end

  def threefold_repetition?(_history)
    false # TO DO, probably should be implemented as boardstate hash counting occurances in chess.rb, future me issue
  end

  def can_castle?(algebraic_notation, active_player)
    row = active_player == 'white' ? 0 : 7
    unless board[row][4].is_a?(King) && board[row][4].color == active_player && !board[row][4].moved? && !is_safe?([row, 4], active_player)
      puts '## King either moved or is directly thretened'
      return false
    end

    if algebraic_notation == 'O-O-O'
      (1..3).each do |column|
        unless board[row][column] == ' ' && !is_safe?([row, column], active_player)
          puts "Position #{('a'.ord + column).chr}#{row+1} is either occupied or directly thretened"
          return false
        end
      end
      unless board[row][0].is_a?(Rook) && board[row][0].color == active_player && !board[row][0].moved? && !is_safe?([row, 0], active_player)
        puts "Rook at #{('a'.ord + column).chr}#{row+1}either moved or the position is directly thretened"
        return false
      end
    else
      (5..6).each do |column|
        unless board[row][column] == ' ' && !is_safe?([row, column], active_player)
          puts "Position #{('a'.ord + column).chr}#{row+1} is either occupied or directly thretened"
          return false
        end
      end
      unless board[row][7].is_a?(Rook) && board[row][7].color == active_player && !board[row][7].moved? && !is_safe?([row, 7], active_player)
        puts "Rook at #{('a'.ord + column).chr}#{row+1} either moved or the position is directly thretened"
        return false
      end
    end

    true
  end

  def deep_copy(obj)
    Marshal.load(Marshal.dump(obj))
  end

  def king_would_be_in_check?(algebraic_notation, active_player)
    board_state = deep_copy(board)
    move(algebraic_notation, active_player)
    out = is_safe?(king_doko(active_player), active_player)
    self.board = board_state
    out
  end

  def enemy_would_be_in_check?(algebraic_notation, active_player)
    board_state = deep_copy(board)
    move(algebraic_notation, active_player)
    out = is_safe?(king_doko(active_player == 'white' ? 'black' : 'white'), active_player == 'white' ? 'black' : 'white')
    self.board = board_state
    out
  end

  def would_conclude?(algebraic_notation, active_player, history)
    board_state = deep_copy(board)
    move(algebraic_notation, active_player)
    out = concluded?(history.dup << algebraic_notation)
    self.board = board_state
    out
  end

  def king_doko(active_player)
    (0..7).each do |row|
      (0..7).each do |column|
        next if board[row][column] == " "

        return [row, column] if board[row][column].is_a?(King) && board[row][column].color == active_player
      end
    end
    puts '## Faild to find active king'
    raise StandardError
  end

  def is_safe?(position, active_player)
    [[2, 1], [2, -1], [1, 2], [-1, 2], [-2, 1], [-2, -1], [1, -2], [-1, -2]].each do |mv|
      next if position[0] + mv[0] > 7 || position[0] + mv[0] < 0 || position[1] + mv[1] > 7 || position[1] + mv[1] < 0

      return false if board[position[0] + mv[0]][position[1] + mv[1]].is_a?(Knight) && board[position[0] + mv[0]][position[1] + mv[1]].color != active_player
    end

    [[[1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0]],
    [[-1, 0], [-2, 0], [-3, 0], [-4, 0], [-5, 0], [-6, 0], [-7, 0]],
    [[0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7]],
    [[0, -1], [0, -2], [0, -3], [0, -4], [0, -5], [0, -6], [0, -7]]].each do |direction|
      direction.each do |laser|
        break if position[0] + laser[0] > 7 || position[0] + laser[0] < 0 || position[1] + laser[1] > 7 || position[1] + laser[1] < 0
        next if board[position[0] + laser[0]][position[1] + laser[1]] == " "
        break if board[position[0] + laser[0]][position[1] + laser[1]].color == active_player

        return true if board[position[0] + laser[0]][position[1] + laser[1]].is_a?(Rook) || board[position[0] + laser[0]][position[1] + laser[1]].is_a?(Queen)
        break
      end
    end

    [[[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7]],
    [[-1, 1], [-2, 2], [-3, 3], [-4, 4], [-5, 5], [-6, 6], [-7, 7]],
    [[1, -1], [2, -2], [3, -3], [4, -4], [5, -5], [6, -6], [7, -7]],
    [[-1, -1], [-2, -2], [-3, -3], [-4, -4], [-5, -5], [-6, -6], [-7, -7]]].each do |direction|
      direction.each do |laser|
        break if position[0] + laser[0] > 7 || position[0] + laser[0] < 0 || position[1] + laser[1] > 7 || position[1] + laser[1] < 0
        next if board[position[0] + laser[0]][position[1] + laser[1]] == " "
        break if board[position[0] + laser[0]][position[1] + laser[1]].color == active_player

        return true if board[position[0] + laser[0]][position[1] + laser[1]].is_a?(Bishop) || board[position[0] + laser[0]][position[1] + laser[1]].is_a?(Queen)
        break
      end
    end

    pawn_captures = active_player == 'white' ? [[-1, -1], [-1, 1]] : [[1, -1], [1, 1]]
    pawn_captures.each do |laser|
      next if position[0] + laser[0] > 7 || position[0] + laser[0] < 0 || position[1] + laser[1] > 7 || position[1] + laser[1] < 0
      
      return true if board[position[0] + laser[0]][position[1] + laser[1]].is_a?(Pawn) && board[position[0] + laser[0]][position[1] + laser[1]].color != active_player
    end

    [[1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]].each do |laser|
      next if position[0] + laser[0] > 7 || position[0] + laser[0] < 0 || position[1] + laser[1] > 7 || position[1] + laser[1] < 0

      return true if board[position[0] + laser[0]][position[1] + laser[1]].is_a?(King) && board[position[0] + laser[0]][position[1] + laser[1]].color != active_player
    end

    false
  end

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

        next unless (origin[0].nil? || origin[0] == target[0] - move[0]) && (origin[1].nil? || origin[1] == target[1] - move[1])

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

        next unless (origin[0].nil? || origin[0] == target[0] - move[0]) && (origin[1].nil? || origin[1] == target[1] - move[1])

        return [target[0] + move[0], target[1] + move[1]]
      end
    end

    puts '## Failed to find the Bishop'
    raise StandardError
  end

  def find_knight(origin, active_player)
    moves = [[2, 1], [2, -1], [1, 2], [-1, 2], [-2, 1], [-2, -1], [1, -2], [-1, -2]]

    moves.each do |move|
      next if target[0] + move[0] < 0 || target[0] + move[0] > 7 || target[1] + move[1] < 0 || target[1] + move[1] > 7

      candidate = board[target[0] + move[0]][target[1] + move[1]]

      next if candidate == ' '

      next unless candidate.is_a?(Knight) && candidate.color == active_player

      next unless (origin[0].nil? || origin[0] == target[0] - move[0]) && (origin[1].nil? || origin[1] == target[1] - move[1])

      return [target[0] + move[0], target[1] + move[1]]
    end

    puts '## Failed to find the Knight'
    raise StandardError
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

        next unless (origin[0].nil? || origin[0] == target[0] - move[0]) && (origin[1].nil? || origin[1] == target[1] - move[1])

        return [target[0] + move[0], target[1] + move[1]]
      end
    end

    puts '## Failed to find the Rook'
    raise StandardError
  end

  def find_pawn(origin, active_player)
    if active_player == 'white'
      moves = capture ? [[1, 1], [1, -1]] : [[1, 0], [2, 0]]
    else
      moves = capture ? [[-1, 1], [-1, -1]] : [[-1, 0], [-2, 0]]
    end

    moves.each do |move|
      next if target[0] - move[0] < 0 || target[0] - move[0] > 7 || target[1] - move[1] < 0 || target[1] - move[1] > 7

      candidate = board[target[0] - move[0]][target[1] - move[1]]

      next if candidate == ' '

      next if move[0].abs == 2 && candidate.moved?

      next unless candidate.is_a?(Pawn) && candidate.color == active_player

      next unless (origin[0].nil? || origin[0] == target[0] - move[0]) && (origin[1].nil? || origin[1] == target[1] - move[1])

      return [target[0] - move[0], target[1] - move[1]]
    end

    puts '## Failed to find the Pawn'
    raise StandardError
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
