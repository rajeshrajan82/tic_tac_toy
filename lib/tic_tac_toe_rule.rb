module TicTacToeRule
  POSSIBLE_WAY_SET = [[1, 2, 3], [4, 5, 6], [7, 8, 9], 
                    [1, 4, 7], [2, 5, 8], [3, 6, 9], 
                    [1, 5, 9], [3, 5, 7]]

  PICK_NUMBERS = (1..9).to_a
  class << self
    def find_possiblity?(picked_values, choose_number)
      TicTacToeRule::POSSIBLE_WAY_SET.each do |possible_set|
        next if !possible_set.include?(choose_number)
        possible_values = possible_set.select {|number| number == choose_number || picked_values.include?(number)}
        return true if possible_values.size == possible_set.size
      end
      false
    end
    
    def get_win_number(possible_list)
      last_result = 0
      choose_number = 0
      possible_list.each do |key, value|
        if value > last_result
          last_result = value
          choose_number = key
        end
      end
      choose_number
    end  
  end
end
