# frozen_string_literal: true

module Helper
    # vod => arr_of_matched_idx
    def matched(a_arr, b_arr)
      arr_of_matched_idx = [];
      a_arr.each_with_index do |e, i|
        if e == b[i]
          arr_of_matched_idx.push(i)
        end
      end
    end

    def match_value(my_arr, guess_arr)
      my_arr.group_by
    end
    
end

module Mastermind
  CODE_SIZE = 4
  # 4 code pegs class
  class Code
    def self.create_random_code
      random_4_nums = [1..CODE_SIZE].map { rand(0...CODE_SIZE) }
      Code.new(*random_4_nums)
    end

    def initialize(num1, num2, num3, num4)
      @elements = [num1, num2, num3, num4]
    end

    def elements
      elements.clone
    end

    # return {correct_both: ; correct_color_not_position: }
    def compare_with(b_code)
      my_element = elements
      b_elements = b_code.elements
      correct_both = 0
      correct_color_not_position = 0;
      
      matched_idxs = Helper.matched(my_element, b_elements)

    end


  end

  class Player
    def initialize(name)
      @name = name
    end
  end

  class ComputerPlayer < Player
    def initialize
      super('Computer')

    end

    def create_secret_code
      SecretCode.create_random_code
    end

    def give_feedback
      
    end
  end

  class CodeMaker
    attr_accessor :player

    def initialize(player)
      @player = player
      @code = nil
    end

    def create_secret_code
      self.code = player.create_secret_code
    end

    def give_feedback(guess_code)
      # return {}
      
    end

    private
    attr_accessor :code
  end
end
