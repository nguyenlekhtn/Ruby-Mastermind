# frozen_string_literal: true

require_relative 'helper'

module Mastermind
  TURNS = 12
  PEGS = 4
  COLORS = 6

  # Game of mastermind, init with number of pegs and number of colors correspondingly
  class Game
    def initialize
      @history = []
      @current_turn = 0
    end

    attr_reader :pegs, :colors, :codebreaker, :codemaker, :current_turn, :history

    def add_history(guess_code, black_num, white_num)
      @history << { guess_code: guess_code, feedback: { black_num: black_num, white_num: white_num } }
    end

    def last_guess
      history.dig(-1, :guess_code)
    end

    def last_feedback
      history[-1][:feedback]
    end

    def first_turn?
      current_turn.zero?
    end

    def play_turn(turn_i)
      puts "Turn #{turn_i + 1}"
      # require 'pry-byebug'; binding.pry
      guess_code = @codebreaker.guess

      puts "#{codebreaker.name} guessed #{guess_code}"
      (__m__ = (@codemaker.give_feedback(guess_code))) && ((__m__.respond_to?(:deconstruct_keys) && (((__m_hash__ = __m__.deconstruct_keys([:black_num, :white_num])) || true) && (Hash === __m_hash__ || Kernel.raise(TypeError, "#deconstruct_keys must return Hash"))) && ((__m_hash__.key?(:black_num) && __m_hash__.key?(:white_num)) && (((black_num = __m_hash__[:black_num]) || true) && ((white_num = __m_hash__[:white_num]) || true)))) || Kernel.raise(NoMatchingPatternError, __m__.inspect))
      puts "#{codemaker.name}'s feedback: B#{black_num}W#{white_num}"
      return 'found' if black_num == PEGS

      add_history(guess_code, black_num, white_num)
      puts "\n"
    end

    def create_secret_code_phase
      @codemaker.create_secret_code
      puts "#{codemaker.name} created secret code"
    end

    def set_role
      print 'Do you want to be codemaker? (y/n): '
      loop do
        answer = gets.chomp
        flag = false
        case answer
        when 'y'
          @codemaker = Codemaker.new(Human.new)
          @codebreaker = Codebreaker.new(AI.new(self))
          flag = true
        when 'n'
          @codemaker = Codemaker.new(AI.new(self))
          @codebreaker = Codebreaker.new(Human.new)
          flag = true
        else
          puts 'Invalid choice, choose again: '
        end
        break if flag
      end
    end

    def start
      set_role
      create_secret_code_phase
      result = nil
      TURNS.times do |turn_i|
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
    def initialize(entity)
      @secret_code = nil
      @entity = entity
    end

    attr_reader :secret_code, :entity

    def give_feedback(guess_code)
      # guess_code = game.last_guess
      (__m__ = compare_with(secret_code.pegs, guess_code.pegs)) && ((__m__.respond_to?(:deconstruct_keys) && (((__m_hash__ = __m__.deconstruct_keys([:count_match_exactly, :count_wrong_pos])) || true) && (Hash === __m_hash__ || Kernel.raise(TypeError, "#deconstruct_keys must return Hash"))) && ((__m_hash__.key?(:count_match_exactly) && __m_hash__.key?(:count_wrong_pos)) && (((count_match_exactly = __m_hash__[:count_match_exactly]) || true) && ((count_wrong_pos = __m_hash__[:count_wrong_pos]) || true)))) || Kernel.raise(NoMatchingPatternError, __m__.inspect))
      { black_num: count_match_exactly, white_num: count_wrong_pos }
    end

    def create_secret_code
      @secret_code = entity.set_code
    end

    def name
      entity.name
    end
  end

  class Codebreaker
    def initialize(entity)
      @entity = entity
    end

    attr_reader :entity

    def guess
      entity.guess
    end

    def name
      entity.name
    end
  end

  class Human
    def initialize
      @name = 'Human'
    end

    attr_reader :name

    def set_code
      print 'Enter secret code: '
      Code.from_input
    end

    def guess
      print 'Enter your guess: '
      Code.from_input
    end
  end

  class AI
    def initialize(game)
      @name = 'AI'
      @game = game
      @valid_choices = possible_choices(1, COLORS, PEGS)
    end

    attr_reader :name, :game, :valid_choices

    def set_code
      Code.create_random_code
    end

    # choice: Array, guess: Code
    def receive_same_feedback?(choice, feedback, guess)
      match_compare?(choice, guess.pegs, feedback.values)
    end

    def remove_invalid_choice
      last_feedback = game.last_feedback
      last_guess = game.last_guess
      @valid_choices.select! { |choice| receive_same_feedback?(choice, last_feedback, last_guess) }
    end

    def select_valid_choice
      Code.new(*valid_choices[0])
    end

    def guess
      return Code.new(*%w[1 1 2 2]) if game.first_turn?

      remove_invalid_choice
      select_valid_choice
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

    def to_s
      pegs.join
    end
  end
end