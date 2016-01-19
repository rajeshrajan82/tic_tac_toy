module TicTacToeRule
  POSSIBLE_3X3_SET = [[1, 2, 3], [4, 5, 6], [7, 8, 9], 
                    [1, 4, 7], [2, 5, 8], [3, 6, 9], 
                    [1, 5, 9], [3, 5, 7]]

  POSSIBLE_4X4_SET = [[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12], [13, 14, 15, 16], 
                    [1, 5, 9, 13], [2, 6, 10, 14], [3, 7, 11, 15], [4, 8, 12, 16], 
                    [1, 6, 11, 16], [4, 7, 10, 13]]

  POSSIBLE_5X5_SET = [[1, 2, 3, 4, 5], [6, 7, 8, 9, 10], [11, 12, 13, 14, 15], [16, 17, 18, 19, 20], [21, 22, 23, 24, 25],
                    [1, 6, 11, 16, 21], [2, 7, 12, 17, 22], [3, 8, 13, 18, 23], [4, 9, 14, 19, 24], [5, 10, 15, 20, 25],
                    [1, 7, 13, 19, 25], [5, 9, 13, 17, 21]]

  class << self
    def find_possiblity?(picked_values, choose_number, possible_way_set)
      possible_way_set.each do |possible_set|
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
    
    def get_block_number(user_picked_values, host_picked_values, possible_way_set, number)
      record = 0
      possible_way_set.each do |possible_set|          
        next if !possible_set.include?(number)
        record += 1 if !possible_set.select {|element| user_picked_values.include?(element)}.empty? &&
          possible_set.select {|element| host_picked_values.include?(element)}.empty?
      end
      record
    end
    
    def get_win_possiblity_number(valid_numbers, host_picked_values, possible_way_set, number)
      result = 0   
      possible_way_set.each do |possible_set|      
        next unless possible_set.include?(number)        
        possible_set.each do |element|
          next_val = (!valid_numbers.include?(element) && !host_picked_values.include?(element)) ? -1 : 1
          result = result + next_val
        end
      end
      result
    end
    
    def is_user_won?(picked_values, possible_way_set)
      possible_way_set.each do |possible_set|
        possible_values = possible_set.select{|number| picked_values.include?(number)}
        return true if possible_values.size == possible_set.size
      end
      false
    end
  end
end
