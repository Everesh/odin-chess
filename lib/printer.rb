module Printer

  def print_welcome
    puts '+--------------+'
    puts '| Chess 1.0.0  |'
    puts '| Everesh 2024 |'
    puts '+--------------+'
  end

  def list(arr)
    arr.each_with_index { |elem, index| puts "#{index} #{elem.to_s}" }
  end

  def print_state
    puts '    A   B   C   D   E   F   G   H'
    puts '  +---+---+---+---+---+---+---+---+'
    8.times do |row|
      print "#{8 - row} |"
      8.times { |column| print " #{board.board[7 - row][column].chr} |" }
      puts " #{8 - row}"
      puts '  +---+---+---+---+---+---+---+---+'
    end
    puts '    A   B   C   D   E   F   G   H'
  end

end
