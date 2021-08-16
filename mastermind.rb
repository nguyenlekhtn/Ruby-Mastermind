# frozen_string_literal: true

module Enumerable
  def count_by(&block)
    list = group_by(&block).map { |key, items| [key, items.count] }.sort_by(&:last)
    Hash[list]
  end
end

module Helper
  DEBUG = false

  def log_debug(message)
    puts "#{self}: #{message}" if DEBUG
  end
  module_function :log_debug
end

module ArrayCompare
  # extend self

  # def count_matched_pos_only(target_arr, compare_arr)
  #   target_arr.filter.with_index { |_e, i| target_arr[i] == compare_arr[i] }.length
  # end

  # def count_matched_value_not_pos(target_arr, compare_arr)
  #   not_matched_compare_arr = compare_arr.reject.with_index { |_e, i| target_arr[i] == compare_arr[i] }
  #   not_matched_target_arr = target_arr.reject.with_index { |_e, i| target_arr[i] == compare_arr[i] }
  #   # require 'pry-byebug'; binding.pry
  #   not_matched_target_arr.reduce(0) do |a, v|
  #     index = not_matched_compare_arr.index v
  #     if index
  #       not_matched_compare_arr.delete_at index
  #       a + 1
  #     else
  #       a
  #     end
  #   end
  # end

  def not_match_pos(target_arr, compare_arr)
    not_matched_compare_arr = compare_arr.reject.with_index { |_e, i| target_arr[i] == compare_arr[i] }
    not_matched_target_arr = target_arr.reject.with_index { |_e, i| target_arr[i] == compare_arr[i] }
    [not_matched_target_arr, not_matched_compare_arr]
  end

  def match_value_idx_arr(target_arr, compare_arr)
    # require 'pry-byebug'; binding.pry
    compare_arr.each_with_object([]).with_index do |(c_value, arr), idx|
      target_arr.each do |t_value|
        arr << idx if c_value == t_value && !arr.include?(idx)
      end
    end
  end

  def count_matched_pos_only(target_arr, compare_arr)
    target_arr.length - not_match_pos(target_arr, compare_arr)[0].length
  end

  def count_matched_value_not_pos(target_arr, compare_arr)
    match_value_idx_arr(*not_match_pos(target_arr, compare_arr)).length
  end

  # def compare_arr(a_arr, b_arr)
  #   match_pos_indexes = []
  #   match_value_indexes = []
  #   a_arr.each_with_index do |a, a_idx|
  #     b_arr.each_with_index do |b, b_idx|
  #       if a == b && a_idx == b_idx
  #         match_pos_indexes << b_idx
  #       elsif a == b
  #         match_value_indexes << b_idx unless match_pos_indexes.include? b_idx
  #       end
  #     end
  #   end
  #   { match_pos_indexes: match_pos_indexes, match_value_indexes: match_value_indexes }
  # end
  module_function :count_matched_pos_only, :not_match_pos, :match_value_idx_arr, :count_matched_value_not_pos
end

module Mastermind
  CODE_SIZE = 4
  COLOR_NUM = 6
  TURNS = 12

  class CodeBreaker
    def initialize; end
    # def give_guess_code
    #   @player.give_guess_code(game.guess_history)
    # end
  end

  class CodeBreakerHuman < CodeBreaker
    def guess_code
      code = 1111
      print 'Put your guess code (1122): '
      loop do
        code = gets.chomp
        Helper.log_debug "#{__method__} guess code input: #{code}"
        break if code.match(/[1-#{COLOR_NUM}]{4}/)

        print 'Invalid code, type again: '
      end
      code.split('')
    end
  end

  # CodeBreaker - Compuer Player
  class CodeBreakerAI < CodeBreaker
    # last guess info: match_pos_hash, math_color_arr
    # match_pos_hash: pos:color
    def guess_with_hint(last_guess_info)
      match_pos_hash = last_guess_info[:match_pos_arr]
      match_color_arr = last_guess_info[:match_pos_arr]
      guess_code = Array(CODE_SIZE)
      guess_code.each_with_index do |_e, i|
        guess_code[i] = if match_pos_hash.keys.include? i
                          match_pos_hash[i]
                        elsif !match_color_arr.empty?
                          match_color_arr.pop
                        else
                          Math.rand(1..COLOR_NUM).to_s
                        end
      end
      guess_code
    end

    def guess_code(last_guess_info)
      puts 'AI is guessing'
      if turn.zero?
        (1..CODE_SIZE).map { rand(1..COLOR_NUM).to_s }
      else
        guess_with_hint last_guess_info
      end
    end
  end

  class CodeMaker
    def initialize
      @code = []
    end

    include ArrayCompare

    def feedback(guess_code)
      #   black_pegs, white_pegs = code.compare_with(guess_code)
      #   { black_pegs: black_pegs, white_pegs: white_pegs }
      count_matched_pos_only = count_matched_pos_only(guess_code, @code)
      count_matched_value_not_pos = count_matched_value_not_pos(guess_code, @code)
      { black_pegs: count_matched_pos_only, white_pegs: count_matched_value_not_pos }
    end

    def match_secret_code?(guess_code)
      count_matched_pos_only(@code, guess_code) == CODE_SIZE
    end
  end

  class CodeMakerAI < CodeMaker
    def create_secret_code(code = nil)
      @code = if code.nil?
                (1..CODE_SIZE).map { rand(1..COLOR_NUM).to_s }
              else
                code.to_s.split('')
              end
      puts 'CodeMaker created secret code'
      puts @code.join
    end
  end

  class CodeMakerHuman < CodeMaker
    def hint guess_code
      match_pos_hash = Hash.new(0)
      guess_code.each_with_index do |_e, idx|
        if guess_code[idx] == @code[idx]
          match_pos_hash[idx] = guess_code[idx]
        else

        end
      end
    end
  end

          




  class Game
    include Helper

    def initialize
      @code_breaker = CodeBreakerHuman.new
      @code_maker = CodeMakerAI.new
      @guess_attemps = Array.new(TURNS) { [] }
      @feedback_log = Array.new(TURNS) { nil }
      @turn = 1
    end

    def play
      # require 'pry-byebug'; binding.pry
      code_maker.create_secret_code 1234
      while turn <= TURNS
        puts "\nTurn #{turn}"
        place_guess
        if code_matched?
          puts 'Codebreaker won'
          return
        end
        if turn == TURNS
          puts 'Codemaker won'
          return
        end
        place_feedback
        @turn += 1
      end
      puts 'Codemaker won'
    end

    private

    attr_accessor :turn, :guess_attemps, :feedback_log
    attr_reader :code_breaker, :code_maker

    def print_board
      if turn == 1
        puts 'First attempt: '
      else
        puts 'Board: '
        (1...turn).each do |i|
          black_pegs = feedback_log[i - 1][:black_pegs]
          white_pegs = feedback_log[i - 1][:white_pegs]
          puts "Turn #{i}, Guess attempt: #{guess_attemps[i - 1].join('')}, black: #{black_pegs} - white: #{white_pegs}"
        end
      end
    end

    def place_guess
      print_board
      guess_code = code_breaker.guess_code
      Helper.log_debug "#{__method__} guess_code: #{guess_code}"
      guess_attemps[turn - 1] = guess_code
    end

    def place_feedback
      feedback = code_maker.feedback(guess_attemps[turn - 1])
      log_debug "#{__method__} feedback: #{feedback}"
      feedback_log[turn - 1] = feedback
      puts "Feedback: black: #{feedback[:black_pegs]} - white: #{feedback[:white_pegs]}"
    end

    def code_matched?
      code_maker.match_secret_code? guess_attemps[turn - 1]
    end
  end
end

# new_game = Mastermind::Game.new
# new_game.play
a = [4, 1, 4, 1]
b = [4, 0, 1, 4]
p ArrayCompare.count_matched_value_not_pos(a, b)