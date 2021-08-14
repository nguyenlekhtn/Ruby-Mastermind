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

  def count_matched_pos_only(target_arr, compare_arr)
    target_arr.filter.with_index { |_e, i| target_arr[i] == compare_arr[i] }.length
  end

  def count_matched_value_not_pos(target_arr, compare_arr)
    temp_compare_arr = compare_arr.clone
    target_arr.reject.with_index { |_e, i| target_arr[i] == compare_arr[i] }.reduce(0) do |a, v|
      index = temp_compare_arr.index v
      unless index.nil?
        temp_compare_arr.delete_at index
        return a + 1
      end
      a
    end
  end
end

module Mastermind
  CODE_SIZE = 4
  TURNS = 12
  DEBUG = false

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

  #   # return [correct_both, correct_value_not_position]
  #   def compare_with(guess_code)
  #     my_elements = elements
  #     guess_elements = guess_code.elements
  #     matched_position_indexes = Helper.get_match_pos_value_indexes
  #     filter_my_elements = my_elements.clone
  #     filter_guess_elements = guess_elements.clone
  #     filter_guess_elements, filter_my_elements = Helper.delete_with_index(matched_position_indexes,
  #                                                                          [filter_guess_elements, filter_my_elements])
  #     match_value_count = Helper.match_value(filter_my_elements, filter_guess_elements)
  #     [matched_position_indexes.length, match_value_count]
  #   end
  # end

  # class Player
  #   def initialize(name)
  #     @name = name
  #   end
  # end

  def log(things)
    puts things if DEBUG
  end

  class CodeMaker
    def initialize
      @code = []
    end

    def feedback(guess_code)
      #   black_pegs, white_pegs = code.compare_with(guess_code)
      #   { black_pegs: black_pegs, white_pegs: white_pegs }
      count_matched_pos_only = Helper.count_matched_pos_only(guess_code, code)
      count_matched_value_not_pos = Helper.count_matched_value_not_pos(guess_code, code)
      { black_pegs: count_matched_pos_only, white_pegs: count_matched_value_not_pos }
    end

    def match_secret_code?(guess_code)
      count_matched_pos_only(code, guess_code).length == CODE_SIZE
    end

    private

    attr_reader :code

    def code=(code)
      @code = code
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
      print 'Put your guess code (1122): '
      loop do
        code = gets.chomp
        Mastermind.log "#{__method__} guess code input: #{code}"
        break if code.match(/\d{4}/)

        print 'Invalid code, type again: '
      end
      code
    end
  end

  class CodeMakerAI < CodeMaker
    def create_secret_code
      code = [1..CODE_SIZE].map { rand(0...CODE_SIZE) }
      puts 'CodeMaker created secret code'
    end
  end



  class Game

    def initialize
      @code_breaker = CodeBreakerHuman.new
      @code_maker = CodeMakerAI.new
      @guess_attemps = Array.new(TURNS) { [] }
      @feedback_log = Array.new(TURNS) { nil }
      @turn = 1
    end

    def play
      code_maker.create_secret_code
      while turn < TURNS

        place_guess {}
        if code_matched?
          puts 'Codebreaker won'
          return
        elsif turn == TURNS
          puts 'Codemaker won'
          return
        else
          place_feedback
        end
      end
      puts 'Codemaker won'
    end

    private

    attr_accessor :turn, :guess_attemps, :feedback_log
    attr_reader :code_breaker, :code_maker

    def print_board
      (1..turn).each do |i|
        puts "Turn #{turn}, Guess attempt: #{guess_attemps[i - 1]}, feedback: #{feedback_log[i - 1]}"
      end
    end


    def place_guess
      print_board
      guess_code = code_breaker.guess_code
      log "#{__method__} guess: #{guess}"
      guess_attemps[turn - 1] = guess_code
    end

    def place_feedback
      feedback = code_maker.feedback(guess_code)
      log "#{__method__} feedback: #{feedback}"
      feedback_log[turn - 1] = feedback
    end

    def code_matched?
      code_maker.match_secret_code? guess_attemps[turn]
    end
  end
end

new_game = Mastermind::Game.new
new_game.play
