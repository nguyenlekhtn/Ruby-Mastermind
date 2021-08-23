# frozen_string_literal: true

module Mastermind
  TURNS = 12
  PEGS = 4
  COLORS = 6

  # Game of mastermind, init with number of pegs and number of colors correspondingly
  class Game
    def initialize(_pegs, _colors)
      @history = Array(TURNS) { { guess_code: nil, feedback: nill } }
      @valid_codes = []
    end

    attr_reader :pegs, :colors, :valid_codes, :codebreaker, :codemaker

    def add_history(turn_i, guess_code, black_num, white_num)
      @history[turn_i][:guess_code] = guess_code
      @history[turn_i][:feedback] = { black_num: black_num, white_num: white_num }
    end

    def play_turn(turn_i)
      guess_code = @codemaker.guess
      return true if black_num == pegs

      (@codebreaker.give_feedback guess_code) => {black_num:, white_num:}
      add_history(turn_i, guess_code, black_num, white_num)
    end

    def start
      @codebreaker.create_secret_code
      result = false
      TURNS.times do |turn_i|
        result = play_turn turn_i
        break if result
      end
      if result then puts "#{codebreaker.name} won"
      else puts "#{codemaker.name} won"
      end
    end
  end

  class Codemaker
    def initialize
      @secret_code = nil
    end

    attr_reader :secret_code
  end

  class CodemakerHuman < Codemaker
    def initialize
      super
      @name = 'Human'
    end

    def create_secret_code
      print 'Enter secret code: '
      @secret_code = Code.from_input
    end
  end

  class CodemakerAI < Codemaker
    def initialize
      super
      @name = 'AI'
    end

    def create_secret_code
      @secret_code = Code.create_random_code
    end
  end

  class Code
    def initialize(num1, num2, num3, num4)
      @pegs = [num1, num2, num3, num4]
    end

    attr_accessor :pegs

    def self.valid?(input)
      input.match?(/^[1-#{COLORS}]{#{PEGS}}$/)
    end

    def self.from_input
      input = ''
      loop do
        input = gets.chomp
        break if Code.valid? input
      end
      Code.new(*input.chars)
    end

    def self.create_random_code
      # create a 4 pegs random number from 1 to PEGS
      random = (1..PEGS).to_a.map { rand(1..COLORS).to_s }
      Code.new(*random)
    end
  end
end

p Mastermind::Code.from_input
