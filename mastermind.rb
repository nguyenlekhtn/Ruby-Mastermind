# frozen_string_literal: true

module Enumerable
  def count_by(&block)
    list = group_by(&block).map { |key, items| [key, items.count] }.sort_by(&:last)
    Hash[list]
  end
end

module Helper
  # vod => arr_of_matched_idx
  # def get_match_pos_value_indexes(a_arr, b_arr)
  #   arr_of_matched_idx = []
  #   a_arr.each_with_index do |e, i|
  #     arr_of_matched_idx.push(i) if e == b_arr[i]
  #   end
  #   arr_of_matched_idx
  # end

  # def delete_with_index(idx_arr, arr_list)
  #   idx_arr.each do |idx|
  #     arr_list.each do |arr|
  #       arr.delete_at(idx)
  #     end
  #   end

  #   arr_list
  # end

  # return num of element guess_arr extacly match value of my_arr
  # def match_value(my_arr, guess_arr)
  #   count = 0
  #   counted_my_arr = my_arr.count_by { |x| x }
  #   counted_guess_arr = guess_arr.count_by { |x| x }
  #   counted_guess_arr.each do |k, _v|
  #     count += [counted_my_arr[k], counted_guess_arr].min if counted_my_arr.key? k
  #   end
  #   # intersection 2 hash to find min
  #   # counted_my_arr.select { |k, _v| counted_guess_arr.key? k }
  #   #               .map { |k, v| [k, [v, counted_guess_arr[k]].min] }
  #   #               .to_h
  #   count
  # end

  DEBUG = false

  def log_debug(message)
    puts "#{self}: #{message}" if DEBUG
  end
  module_function :log_debug
end

module ArrayCompare
  def count_matched_pos_only(target_arr, compare_arr)
    target_arr.filter.with_index { |_e, i| target_arr[i] == compare_arr[i] }.length
  end

  def count_matched_value_not_pos(target_arr, compare_arr)
    not_matched_compare_arr = compare_arr.reject.with_index { |_e, i| target_arr[i] == compare_arr[i] }
    not_matched_target_arr = target_arr.reject.with_index { |_e, i| target_arr[i] == compare_arr[i] }
    # require 'pry-byebug'; binding.pry
    not_matched_target_arr.reduce(0) do |a, v|
      index = not_matched_compare_arr.index v
      if index
        not_matched_compare_arr.delete_at index
        a + 1
      else
        a
      end
    end
  end
end

module Mastermind
  CODE_SIZE = 4
  COLOR_NUM = 6
  TURNS = 12

  # 4 code pegs class
  # class Code
  #   def self.create_random_code
  #     random_4_nums = [1..CODE_SIZE].map { rand(0...CODE_SIZE) }
  #     Code.new(*random_4_nums)
  #   end

  #   def initialize(num1, num2, num3, num4)
  #     @elements = [num1, num2, num3, num4]
  #   end

  #   def elements
  #     elements.clone
  #   end

  # end

  # class Player
  #   def initialize(name)
  #     @name = name
  #   end
  # end

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

  class CodeMakerAI < CodeMaker
    def create_secret_code(code = nil)
      unless code.nil?
        @code = code.to_s.split('')
      else
        @code = (1..CODE_SIZE).map { rand(1..COLOR_NUM).to_s }
      end
      puts 'CodeMaker created secret code'
      puts @code.join()
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

new_game = Mastermind::Game.new
new_game.play
