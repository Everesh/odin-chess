require_relative 'printer'

SAVES = Dir.entries("./saves").reject { |entry| entry == '.' || entry == '..' }.freeze

class Chess
  include Printer

  def initialize
    print_welcome
    if SAVES.length.positive?
      init_load
    else
      init_new
    end
  end

  def init_load
    puts 'Looks like you have some saves:'
    list(SAVES)
    loading = load_input
    return init_new if loading == -1

    data = YAML.load File.open(SAVES[loading], 'r')
    data.each { |key, val| instance_variable_set("@#{key}", val) }
    play
  end

  def init_new

    @board

  end

  def play

    # TO DO

  end

  private

  def load_input
    puts "Select a files [0 - #{SAVES.length - 1}] or type NEW to create a new game"
    begin
      input = gets.chomp.downcase
      return -1 if input == 'new'

      raise StandardError if input.to_i.negative? || SAVES.length <= input.to_i
    rescue StandardError
      puts '# Wrong input, try again'
      retry
    end
    input.to_i
  end

  def save_as(str)
    File.open('./saves/'.concat(str.concat('.yml')), 'w') do |file|
      YAML.dump(instance_variables.each_with_object({}) { |var, hash| hash[var.to_s.delete('@')] = instance_variable_get(var) }, file)
    end
  end

end
