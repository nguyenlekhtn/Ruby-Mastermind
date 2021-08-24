# frozen_string_literal: true

require_relative 'helper'

module Mastermind
  TURNS = 12
  PEGS = 4
  COLORS = 6

  # Game of mastermind, init with number of pegs and number of colors correspondingly
  class Game
    def initialize
      @history = Array.new(TURNS) { { guess_code: nil, feedback: nil } }
      @valid_codes = []
      @current_turn = 0
      @codemaker = CodemakerAI.new self
      @codebreaker = CodebreakerHuman.new
    end

    attr_reader :pegs, :colors, :valid_codes, :codebreaker, :codemaker, :current_turn, :history

    def add_history(turn_i, guess_code, black_num, white_num)
      @history[turn_i][:guess_code] = guess_code
      @history[turn_i][:feedback] = { black_num: black_num, white_num: white_num }
    end

    def last_guess
      history.dig(current_turn, :guess_code)
    end

    def play_turn(turn_i)
      puts "Turn #{turn_i + 1}"
      # require 'pry-byebug'; binding.pry
      guess_code = @codebreaker.guess

      puts "#{codebreaker.name} guessed #{guess_code}"
      (@codemaker.give_feedback guess_code) => {black_num:, white_num:}
      puts "#{codemaker.name}'s feedback: B#{black_num}W#{white_num}"
      return 'found' if black_num == PEGS

      add_history(turn_i, guess_code, black_num, white_num)
      puts "\n"
    end

    def create_secret_code_phase
      @codemaker.create_secret_code
      puts "#{codemaker.name} created code"
    end

    def start
      create_secret_code_phase
      result = nil
      TURNS.times do |turn_i|
        require 'pry-byebug'; binding.pry
        @current_turn = turn_i
        result = play_turn turn_i
        break if result == 'found'
      end
      if result == 'found' then puts "#{codebreaker.name} won"
      else puts "#{codemaker.name} won"
      end
    end
  end

  class Codemaker
    def initialize(game)
      @secret_code = nil
      @game = game
    end

    attr_reader :secret_code, :game

    def give_feedback(guess_code)
      # guess_code = game.last_guess
      (secret_code.compare_with guess_code) => {count_match_exactly:, count_wrong_pos:}
      { black_num: count_match_exactly, white_num: count_wrong_pos }
    end
  end

  class CodemakerHuman < Codemaker
    def initialize(game)
      super
      @name = 'Human'
    end

    def create_secret_code
      print 'Enter secret code: '
      @secret_code = Code.from_input
    end
  end

  class CodemakerAI < Codemaker
    def initialize(game)
      super
      @name = 'AI'
    end

    attr_reader :name

    def create_secret_code
      # @secret_code = Code.create_random_code
      @secret_code = Code.new(*%w[1 2 3 4])
      puts "Secret code: #{secret_code}"
    end
  end

  class CodebreakerHuman
    def initialize
      @name = 'Human'
    end

    attr_reader :name

    def guess
      print 'Input your guess: '
      Code.from_input
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

        print 'Invalid format, type again: '
      end
      Code.new(*input.chars)
    end

    def self.create_random_code
      # create a 4 pegs random number from 1 to PEGS
      random = (1..PEGS).to_a.map { rand(1..COLORS).to_s }
      Code.new(*random)
    end

    # {count_match_exactly:, count_wrong_pos:}
    def compare_with(code)
      count_match_exactly = count_matched_pos(pegs, code.pegs)
      count_wrong_pos = count_matched_value_only(pegs, code.pegs)
      { count_match_exactly: count_match_exactly, count_wrong_pos: count_wrong_pos }
    end

    def to_s
      pegs.join
    end
  end
end

game = Mastermind::Game.new
game.start
