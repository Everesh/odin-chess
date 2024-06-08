require_relative 'printer'

class Chess
  include Printer

  def initialization
    print_welcome
    if Dir.entries("./saves").length > 0
      init_load
    else
      init_new
    end
  end

  def init_load
    list(Dir.entries("./saves"))
    loading = load_input
    return init_new if loading == -1

    data = YAML.load File.open(Dir.entries("./saves")[loading], 'r')
    data.each { |key, val| instance_variable_set("@#{key}", val) }
    play
  end

  def init_new

    # TO DO

  end

  def play

    # TO DO

  end

  private

  def load_input
    puts "Select a files [0 - #{Dir.entries("./saves").length}] or NEW"
    begin
      input = gets.chomp.downcase
      return -1 if input == 'new'

      raise StandardError if input.to_i.negative? || input.to_i >= Dir.entries("./saves").length
    rescue StandardError
      puts '# Wrong input, try again'
      retry
    end
    input.to_i
  end

end
