class Printer

  def list(arr)
    arr.each_with_index { |elem, index| puts "#{index} #{elem.to_s}" }
  end

end
