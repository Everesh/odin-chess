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

end
