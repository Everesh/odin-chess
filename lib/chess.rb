require_relative 'printer'
require_relative 'board'

require 'yaml'

SAVES = Dir.entries('./saves').reject { |entry| ['.', '..'].include?(entry) }.freeze

class Chess
  include Printer

  attr_reader :board

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

    data = YAML.unsafe_load File.open("./saves/#{SAVES[loading]}", 'r')
    data.each { |key, val| instance_variable_set("@#{key}", val) }
    play
  end

  def init_new
    @board = Board.new
    @active_player = 'white'
    @history = []
    play
  end

  def play
    until board.concluded?
      action = get_action
      break if action == 'save'

      board.move((history << action)[-1])
      print_state
      active_player = active_player == 'white' ? 'black' : 'white'
    end

    conclude(action)
  end

  private

  def get_action
    # validate from board before passing
    # TO DO
    # return action [algebraic notation | save]
  end

  def prompt_save
    puts 'Give me the file name:'
    begin
      file_name = gets.scan(/\w+/)
      raise StandardError if file_name.size != 1 || file_name[0].length < 1
    rescue StandardError
      puts '# Invalid file name, must be at least 1 long and not be separated by white spaces'
      retry
    end
    save_as(file_name)
  end

  def conclude(action)
    if action == 'save'
      prompt_save
      puts 'Game saved. See ya!'
    else
      puts "GGs! #{active_player == 'white' ? 'BLACK' : 'WHITE'} WINS! 🏆"
    end
  end

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
    instance_data = instance_variables.each_with_object({}) do |var, hash|
      hash[var.to_s.delete('@')] = instance_variable_get(var)
    end

    File.open("./saves/#{str}.yml", 'w') do |file|
      YAML.dump(instance_data, file)
    end
  end
end
